pub mod api;
pub mod pages;

use axum::{Router, routing::get};
use crate::state::AppState;

pub fn v1_router() -> Router<AppState> {
    Router::new()
        .nest("/select", api::select::select_router())
        .route("/search", get(api::search::search))
}

pub fn pages_router() -> Router<AppState> {
    pages::pages_router()
}