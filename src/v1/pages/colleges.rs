use askama::Template;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::response::Html;

use crate::{error::AppResult, state::AppState};
use super::render_page;

#[derive(Template)]
#[template(path = "page/colleges.html")]
struct CollegesPage {
    current_page: String,
}

#[derive(Template)]
#[template(path = "partials/colleges_content.html")]
struct CollegesContent {}

pub async fn page(
    State(_state): State<AppState>,
    headers: HeaderMap,
) -> AppResult<Html<String>> {
    render_page(
        &headers,
        CollegesPage { current_page: "colleges".to_string() },
        CollegesContent {},
    )
}