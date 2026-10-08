mod error;
mod state;
mod v1;

use axum::Router;
use sqlx::MySqlPool;
use state::AppState;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use tower_http::services::ServeDir;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();

    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer())
        .init();

    let database_url = std::env::var("DATABASE_URL")?;
    tracing::info!("connecting to db...");
    let db = MySqlPool::connect(&database_url).await?;
    let state = AppState { db };

    let app = Router::new()
        .nest("/api/v1", v1::v1_router())
        .nest_service("/static", ServeDir::new("static"))
        .merge(v1::pages_router())
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;
    tracing::info!("listening on http://0.0.0.0:3000");
    axum::serve(listener, app).await?;
    Ok(())
}