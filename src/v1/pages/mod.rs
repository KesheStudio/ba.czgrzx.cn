mod about;
mod colleges;
mod furniture;
mod home;
mod props;
mod students;

use askama::Template;
use axum::{
    http::HeaderMap,
    response::Html,
    routing::get,
    Router,
};

use crate::{error::AppResult, state::AppState};

pub(crate) fn is_htmx(headers: &HeaderMap) -> bool {
    headers
        .get("HX-Request")
        .and_then(|v| v.to_str().ok())
        .map(|v| v == "true")
        .unwrap_or(false)
}

pub(crate) fn render_page<P, C>(
    headers: &HeaderMap,
    page: P,
    content: C,
) -> AppResult<Html<String>>
where
    P: Template,
    C: Template,
{
    if is_htmx(headers) {
        Ok(Html(content.render()?))
    } else {
        Ok(Html(page.render()?))
    }
}

pub fn pages_router() -> Router<AppState> {
    Router::new()
        .route("/", get(home::page))
        .route("/about", get(about::page))
        .route("/colleges", get(colleges::page))
        .route("/furniture", get(furniture::page))
        .route("/props", get(props::page))
        .route("/students", get(students::page))
}