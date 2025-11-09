use chrono::{DateTime, Utc};
use rocket::fairing::AdHoc;
use rocket::response::status;
use rocket::serde::json::{json, Json, Value};
use rocket::serde::{Deserialize, Serialize};
use rocket::{get, launch, post, routes, State};
use rocket_cors::{AllowedOrigins, CorsOptions};
use std::collections::HashMap;
use std::env;
use std::sync::RwLock;
use uuid::Uuid;

// Data structures
#[derive(Debug, Clone, Serialize, Deserialize)]
struct TarotReading {
    id: Uuid,
    question: String,
    cards: Vec<String>,
    interpretation: String,
    created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
struct CreateReadingRequest {
    question: String,
    cards: Vec<String>,
    interpretation: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    timestamp: DateTime<Utc>,
}

// In-memory storage
type ReadingsStore = RwLock<HashMap<Uuid, TarotReading>>;

// Route handlers
#[get("/")]
fn index() -> Value {
    json!({
        "message": "Tarot Reader API",
        "version": "1.0.0",
        "endpoints": {
            "health": "GET /health",
            "readings": "GET /api/readings",
            "reading": "GET /api/readings/{id}",
            "create_reading": "POST /api/readings"
        }
    })
}

#[get("/health")]
fn health_check() -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "healthy".to_string(),
        timestamp: Utc::now(),
    })
}

#[get("/api/readings")]
fn get_readings(store: &State<ReadingsStore>) -> Json<Vec<TarotReading>> {
    let readings = store.read().unwrap();
    let mut readings_list: Vec<TarotReading> = readings.values().cloned().collect();
    readings_list.sort_by(|a, b| b.created_at.cmp(&a.created_at));
    Json(readings_list)
}

#[get("/api/readings/<id>")]
fn get_reading(store: &State<ReadingsStore>, id: String) -> Option<Json<TarotReading>> {
    let uuid = Uuid::parse_str(&id).ok()?;
    let readings = store.read().unwrap();
    readings.get(&uuid).cloned().map(Json)
}

#[post("/api/readings", data = "<request>")]
fn create_reading(
    store: &State<ReadingsStore>,
    request: Json<CreateReadingRequest>,
) -> status::Created<Json<TarotReading>> {
    let id = Uuid::new_v4();
    let now = Utc::now();

    let reading = TarotReading {
        id,
        question: request.question.clone(),
        cards: request.cards.clone(),
        interpretation: request.interpretation.clone(),
        created_at: now,
    };

    let mut readings = store.write().unwrap();
    readings.insert(id, reading.clone());

    let location = format!("/api/readings/{}", id);
    status::Created::new(location).body(Json(reading))
}

// Configuration
fn configure_cors() -> CorsOptions {
    let allowed_origins = if cfg!(debug_assertions) {
        // In development, allow localhost origins
        AllowedOrigins::some_exact(&[
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://localhost:5173",
            "http://127.0.0.1:5173",
        ])
    } else {
        // In production, read from environment or use default
        match env::var("ALLOWED_ORIGINS") {
            Ok(origins) => {
                let origins: Vec<&str> = origins.split(',').collect();
                AllowedOrigins::some_exact(&origins)
            }
            Err(_) => AllowedOrigins::all(),
        }
    };

    CorsOptions {
        allowed_origins,
        allowed_methods: vec!["GET", "POST", "PUT", "DELETE", "OPTIONS"]
            .into_iter()
            .map(|s| s.parse().unwrap())
            .collect(),
        allowed_headers: rocket_cors::AllowedHeaders::all(),
        allow_credentials: true,
        ..Default::default()
    }
}

fn initialize_sample_data() -> ReadingsStore {
    let mut store = HashMap::new();

    // Add sample readings
    let samples = vec![
        (
            Uuid::new_v4(),
            "What does the future hold for my career?",
            vec!["The Fool".to_string(), "The Magician".to_string(), "The High Priestess".to_string()],
            "The Fool suggests new beginnings and taking a leap of faith in your career. The Magician indicates you have all the tools and skills necessary for success. The High Priestess advises trusting your intuition when making important career decisions.",
            Utc::now() - chrono::Duration::days(2)
        ),
        (
            Uuid::new_v4(),
            "Should I pursue this new relationship?",
            vec!["The Lovers".to_string(), "Two of Cups".to_string(), "The Sun".to_string()],
            "The Lovers card strongly indicates a meaningful connection. The Two of Cups reinforces partnership and mutual attraction. The Sun brings joy and positivity, suggesting this relationship has great potential for happiness.",
            Utc::now() - chrono::Duration::days(1)
        ),
        (
            Uuid::new_v4(),
            "How can I improve my financial situation?",
            vec!["Nine of Pentacles".to_string(), "The Emperor".to_string(), "Three of Wands".to_string()],
            "The Nine of Pentacles suggests financial independence is within reach through self-discipline. The Emperor advises taking control and creating structure in your financial planning. The Three of Wands indicates your long-term investments and planning will pay off.",
            Utc::now()
        ),
    ];

    for (id, question, cards, interpretation, created_at) in samples {
        store.insert(
            id,
            TarotReading {
                id,
                question: question.to_string(),
                cards,
                interpretation: interpretation.to_string(),
                created_at,
            },
        );
    }

    RwLock::new(store)
}

#[launch]
fn rocket() -> _ {
    // Initialize logger
    env_logger::init_from_env(env_logger::Env::default().default_filter_or("info"));

    // Load .env file if it exists (for local development)
    dotenv::dotenv().ok();

    log::info!("Starting Tarot Reader API server (no database)");

    // Initialize in-memory storage with sample data
    let readings_store = initialize_sample_data();

    // Configure CORS
    let cors = configure_cors()
        .to_cors()
        .expect("Failed to configure CORS");

    // Build and launch Rocket
    rocket::build()
        .manage(readings_store)
        .attach(cors)
        .attach(AdHoc::on_response("Server Headers", |_req, res| {
            Box::pin(async move {
                res.set_raw_header("X-API-Version", "1.0.0");
            })
        }))
        .mount(
            "/",
            routes![
                index,
                health_check,
                get_readings,
                get_reading,
                create_reading,
            ],
        )
}
