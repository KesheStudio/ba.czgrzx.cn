use askama::Template;
use askama_web::WebTemplate;
use axum::extract::{Query, State};
use serde::Deserialize;

use crate::{
    error::AppResult,
    state::AppState,
};

#[derive(Template, WebTemplate)]
#[template(path = "v1/search.html")]
pub struct SearchTemplate {
    pub q: String,
    pub results: Vec<String>,
}

#[derive(Deserialize)]
pub struct SearchParams {
    #[serde(default)]
    pub q: String,
}

pub async fn search(
    State(_state): State<AppState>,
    Query(params): Query<SearchParams>,
) -> AppResult<SearchTemplate> {
    let test = [
        "11", "22", "32", "125", "1", "2", "3", "4", "5", "6",
        "7", "8", "9", "10", "12", "13", "14", "15", "16", "17",
        "18", "19", "20", "21", "23", "24", "25", "26", "27", "28",
        "29", "30", "31", "33", "34", "35", "36", "37", "38", "39",
        "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
    ];

    let q = params.q.trim().to_string();

    let results: Vec<String> = if q.is_empty() {
        Vec::new()
    } else {
        test.iter()
            .filter(|s| s.contains(q.as_str()))
            .take(10)
            .map(|s| s.to_string())
            .collect()
    };

    Ok(SearchTemplate { q, results })
}