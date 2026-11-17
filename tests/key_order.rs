use bikebook_data_checks::*;
use serde_json::{Map, Value};

fn order_errors(schemas: &Schemas, path: &str, data: &Value) -> Vec<String> {
    let version = data
        .get("schema_version")
        .and_then(Value::as_str)
        .map(str::to_string);
    let kind = Catalog::kind(path);
    let Some(version) = version.or_else(|| schemas.current_version(kind)) else {
        return vec![format!("{path}: no schema")];
    };
    let id = Schemas::id(kind, &version);
    if !schemas.documents.contains_key(&id) {
        return vec![format!("{path}: no schema {id}")];
    }
    schemas
        .key_order_errors(&id, data)
        .into_iter()
        .map(|error| format!("{path}: {error}"))
        .collect()
}

#[test]
fn every_file_is_in_schema_key_order() {
    let schemas = Schemas::load();
    let problems = Catalog::load()
        .files
        .iter()
        .flat_map(|(path, data)| order_errors(&schemas, path, data))
        .collect();
    assert_none("key order", problems);
}

fn swapped(value: &Value, first: &str, second: &str) -> Value {
    let map = value.as_object().unwrap();
    let mut keys: Vec<&String> = map.keys().collect();
    let (a, b) = (
        keys.iter().position(|key| *key == first).unwrap(),
        keys.iter().position(|key| *key == second).unwrap(),
    );
    keys.swap(a, b);
    Value::Object(
        keys.into_iter()
            .map(|key| (key.clone(), map[key].clone()))
            .collect::<Map<_, _>>(),
    )
}

#[test]
fn a_reordered_file_is_reported() {
    let schemas = Schemas::load();
    let catalog = Catalog::load();
    let path = "vehicle_models/specialized/2025/haul_st.json";
    let model = &catalog.files[path];
    assert_eq!(order_errors(&schemas, path, model), Vec::<String>::new());

    let top = swapped(model, "stock_photo", "geometry_photo");
    assert!(
        order_errors(&schemas, path, &top)
            .iter()
            .any(|error| error.contains("(root)"))
    );

    let mut nested = model.clone();
    let year = nested["years"]
        .as_object()
        .unwrap()
        .keys()
        .next()
        .unwrap()
        .clone();
    let colorway = nested["years"][&year]["colorways"][0].clone();
    nested["years"][&year]["colorways"][0] = swapped(&colorway, "name", "stock_photo");
    assert!(
        order_errors(&schemas, path, &nested)
            .iter()
            .any(|error| error.contains(&format!("/years/{year}/colorways/0")))
    );

    let mut years = model.clone();
    let mut reversed: Vec<(String, Value)> = years["years"]
        .as_object()
        .unwrap()
        .clone()
        .into_iter()
        .collect();
    reversed.push(("1999".to_string(), reversed[0].1.clone()));
    reversed.reverse();
    years["years"] = Value::Object(reversed.into_iter().collect());
    assert!(
        order_errors(&schemas, path, &years)
            .iter()
            .any(|error| error.contains("/years: keys must be ordered"))
    );

    let overlay_path = "vehicle_models/specialized/2025/haul_st_ca.json";
    let overlay = &catalog.files[overlay_path];
    assert_eq!(
        order_errors(&schemas, overlay_path, overlay),
        Vec::<String>::new()
    );
    assert!(!order_errors(&schemas, overlay_path, &swapped(overlay, "id", "base")).is_empty());
}
