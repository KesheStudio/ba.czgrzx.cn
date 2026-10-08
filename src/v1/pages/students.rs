use askama::Template;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::response::Html;

use crate::{error::AppResult, state::AppState};
use super::render_page;

#[derive(Template)]
#[template(path = "page/students.html")]
struct StudentsPage {
    current_page: String,
}

#[derive(Template)]
#[template(path = "partials/students_content.html")]
struct StudentsContent {}

pub async fn page(
    State(_state): State<AppState>,
    headers: HeaderMap,
) -> AppResult<Html<String>> {
    render_page(
        &headers,
        StudentsPage { current_page: "students".to_string() },
        StudentsContent {},
    )
}