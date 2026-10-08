use askama::Template;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::response::Html;

use crate::{error::AppResult, state::AppState};
use super::render_page;

#[derive(Template)]
#[template(path = "page/about.html")]
struct AboutPage {
    current_page: String,
}

#[derive(Template)]
#[template(path = "partials/about_content.html")]
struct AboutContent {}

pub async fn page(
    State(_state): State<AppState>,
    headers: HeaderMap,
) -> AppResult<Html<String>> {
    render_page(
        &headers,
        AboutPage { current_page: "about".to_string() },
        AboutContent {},
    )
}