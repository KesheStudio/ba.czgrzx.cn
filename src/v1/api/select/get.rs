use askama::Template;
use askama_web::WebTemplate;
use axum::extract::State;

use crate::{
    error::AppResult,
    state::AppState,
};

#[derive(Template, WebTemplate)]
#[template(path = "v1/select/star.html")]
pub struct StarTemplate {
    pub title: String,
    pub items: Vec<String>,
}

pub async fn select_star(
    State(_state): State<AppState>,
) -> AppResult<StarTemplate> {
    Ok(StarTemplate {
        title: "Star 列表".into(),
        items: vec!["a".into(), "b".into(), "c".into()],
    })
}