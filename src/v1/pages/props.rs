use askama::Template;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::response::Html;

use crate::{error::AppResult, state::AppState};
use super::render_page;

#[derive(Template)]
#[template(path = "page/props.html")]
struct PropsPage {
    current_page: String,
}

#[derive(Template)]
#[template(path = "partials/props_content.html")]
struct PropsContent {}

pub async fn page(
    State(_state): State<AppState>,
    headers: HeaderMap,
) -> AppResult<Html<String>> {
    render_page(
        &headers,
        PropsPage { current_page: "props".to_string() },
        PropsContent {},
    )
}