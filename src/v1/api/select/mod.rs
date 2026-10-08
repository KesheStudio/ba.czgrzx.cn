use axum::{routing::get, Router};
use crate::state::AppState;

mod get;

pub fn select_router() -> Router<AppState> {
    Router::new()
        .route("/star", get(get::select_star))
}