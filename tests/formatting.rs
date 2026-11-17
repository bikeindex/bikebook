use bikebook_data_checks::*;
use std::fs;

/// Pretty-printed with two spaces and a trailing newline, as the catalog writes it. A file that only parses
/// differently (a duplicate key, a float written another way) comes back different too
#[test]
fn every_json_file_is_pretty_printed() {
    let paths: Vec<String> = data_paths()
        .into_iter()
        .chain(json_paths(SCHEMA_DIRECTORY))
        .collect();
    assert!(paths.len() > 100, "found only {} JSON files", paths.len());
    let problems = paths
        .iter()
        .filter_map(|path| {
            let text = fs::read_to_string(root().join(path)).ok()?;
            match serde_json::from_str(&text) {
                Err(error) => Some(format!("{path}: {error}")),
                Ok(value) => (pretty(&value) != text)
                    .then(|| format!("{path}: isn't pretty-printed as the catalog writes it")),
            }
        })
        .collect();
    assert_none("formatting", problems);
}

#[test]
fn a_reformatted_file_differs() {
    let text = fs::read_to_string(root().join("components/tq/2025/hpr60.json")).unwrap();
    let value: serde_json::Value = serde_json::from_str(&text).unwrap();
    assert_eq!(pretty(&value), text);
    assert_ne!(
        pretty(&value),
        serde_json::to_string(&value).unwrap() + "\n"
    );
    let duplicated = text.replacen("\"id\":", "\"id\": \"c/tq/2025/other\",\n  \"id\":", 1);
    assert_ne!(
        pretty(&serde_json::from_str(&duplicated).unwrap()),
        duplicated
    );
}
