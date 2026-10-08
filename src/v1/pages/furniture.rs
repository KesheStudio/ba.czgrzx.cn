use askama::Template;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::response::Html;

use crate::{error::AppResult, state::AppState};
use super::render_page;

#[derive(Template)]
#[template(path = "page/furniture.html")]
struct FurniturePage {
    current_page: String,
}

#[derive(Template)]
#[template(path = "partials/furniture_content.html")]
struct FurnitureContent {}

pub async fn page(
    State(_state): State<AppState>,
    headers: HeaderMap,
) -> AppResult<Html<String>> {
    render_page(
        &headers,
        FurniturePage { current_page: "furniture".to_string() },
        FurnitureContent {},
    )
}