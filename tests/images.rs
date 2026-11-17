use bikebook_data_checks::*;
use serde_json::{Value, json};

fn image_problems(path: &str, data: &Value) -> Vec<String> {
    let mut found = vec![];
    strings(data, String::new(), &mut found);
    found
        .into_iter()
        .filter(|(_, key, string)| {
            image_url(key, string)
                && !IMAGE_PREFIXES
                    .iter()
                    .any(|prefix| string.starts_with(prefix))
        })
        .map(|(at, _, string)| format!("{path}: {at} isn't in our R2 buckets: {string}"))
        .collect()
}

#[test]
fn every_image_is_served_from_our_r2_buckets() {
    let problems = Catalog::load()
        .files
        .iter()
        .flat_map(|(path, data)| image_problems(path, data))
        .collect();
    assert_none("images", problems);
}

#[test]
fn an_image_elsewhere_is_reported() {
    let model = json!({
        "stock_photo": "https://www.specialized.com/haul.png",
        "years": {"2025": {"colorways": [{"name": "Red", "stock_photo": "https://bikebook.bikeindex.org/a/2025/b_red.png"}]}},
        "sources": ["https://example.com/press/photo.jpg", "https://example.com/spec-sheet.pdf"]
    });
    assert_eq!(
        image_problems("m.json", &model),
        [
            "m.json: /stock_photo isn't in our R2 buckets: https://www.specialized.com/haul.png",
            "m.json: /sources/0 isn't in our R2 buckets: https://example.com/press/photo.jpg"
        ]
    );
}
