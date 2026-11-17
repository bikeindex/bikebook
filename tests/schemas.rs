use bikebook_data_checks::*;
use serde_json::{Value, json};

const NAMES: [&str; 4] = [
    "component",
    "e_vehicle_classification",
    "vehicle_model",
    "vocabulary",
];

fn schema_errors(schemas: &Schemas, catalog: &Catalog) -> Vec<String> {
    let mut validators = std::collections::HashMap::new();
    let current_classification = schemas.current_version("e_vehicle_classification").unwrap();
    catalog
        .files
        .iter()
        .flat_map(|(path, data)| {
            let kind = Catalog::kind(path);
            let version = data
                .get("schema_version")
                .and_then(Value::as_str)
                .unwrap_or(&current_classification)
                .to_string();
            let id = Schemas::id(kind, &version);
            let validator = validators
                .entry(id.clone())
                .or_insert_with(|| schemas.validator(&id));
            let validator = match validator {
                Ok(validator) => validator,
                Err(error) => return vec![format!("{path}: {error}")],
            };
            let mut documents = vec![("", data.clone())];
            // as it's stored, and as the catalog reads it
            if data.get("base").is_some() {
                match catalog.resolve(data) {
                    Ok(resolved) => documents.push((" resolved", resolved)),
                    Err(error) => return vec![format!("{path}: {error}")],
                }
            }
            documents
                .iter()
                .flat_map(|(label, document)| {
                    validator
                        .iter_errors(document)
                        .map(|error| format!("{path}{label}: {} {error}", error.instance_path()))
                        .collect::<Vec<_>>()
                })
                .collect()
        })
        .collect()
}

#[test]
fn each_schema_is_valid_json_schema_at_its_versioned_id() {
    let schemas = Schemas::load();
    let mut problems = vec![];
    for path in json_paths(SCHEMA_DIRECTORY) {
        let name = path
            .trim_start_matches("schemas/")
            .trim_end_matches(".json");
        let document = &parsed(std::slice::from_ref(&path))[&path];
        if !NAMES.contains(&name) {
            problems.push(format!("{path}: isn't one of the published schemas"));
        }
        let id = document
            .get("$id")
            .and_then(Value::as_str)
            .unwrap_or_default();
        let version = schemas.current_version(name).unwrap_or_default();
        if id != Schemas::id(name, &version) || version.split('.').count() != 3 {
            problems.push(format!(
                "{path}: $id {id} isn't {SCHEMA_URL}{name}/v<major.minor.patch>.json"
            ));
        }
        if !jsonschema::meta::is_valid(document) {
            problems.push(format!("{path}: isn't valid JSON Schema"));
        }
        if let Err(error) = schemas.validator(id) {
            problems.push(format!("{path}: {error}"));
        }
    }
    let shared: Vec<Option<String>> = ["vehicle_model", "component", "vocabulary"]
        .iter()
        .map(|name| schemas.current_version(name))
        .collect();
    if shared.windows(2).any(|pair| pair[0] != pair[1]) {
        problems.push(format!(
            "vehicle_model, component and vocabulary share a version, not {shared:?}"
        ));
    }
    assert_none("schemas", problems);
}

#[test]
fn every_file_matches_its_schema() {
    assert_none(
        "schema validation",
        schema_errors(&Schemas::load(), &Catalog::load()),
    );
}

#[test]
fn a_file_breaking_its_schema_is_reported() {
    let schemas = Schemas::load();
    let catalog = Catalog::load();
    let mut broken = catalog.files["components/tq/2025/hpr60.json"].clone();
    broken["bogus"] = json!(1);
    broken["type"] = json!("hovercraft");
    let catalog = Catalog {
        files: [("components/tq/2025/hpr60.json".to_string(), broken)].into(),
    };
    let errors = schema_errors(&schemas, &catalog);
    assert!(
        errors.iter().any(|error| error.contains("/type")),
        "{errors:?}"
    );
    assert!(
        errors.iter().any(|error| error.contains("bogus")),
        "{errors:?}"
    );
}
