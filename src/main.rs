use actix_web::{web, App, HttpServer, Responder, HttpResponse};
use actix_web::http::header;
use futures_util::stream::{self, Stream};
use serde::Deserialize;
use std::pin::Pin;

async fn generate(length: web::Path<i32>) -> impl Responder {
    let len = length.into_inner().max(0) as usize;

    // Create a stream of 'a' characters
    let body_stream: Pin<Box<dyn Stream<Item = Result<web::Bytes, actix_web::Error>>>> =
        Box::pin(stream::iter((0..len).map(|_| {
            Ok::<_, actix_web::Error>(web::Bytes::from_static(b"a"))
        })));

    HttpResponse::Ok()
        .insert_header((header::CONTENT_TYPE, "text/plain"))
        .streaming(body_stream)
}

#[derive(Deserialize)]
struct GenerateParams {
    length: usize,
    chunk_size: Option<usize>, // Optional, with default fallback
}

async fn generate_chunk(query: web::Query<GenerateParams>) -> impl Responder {
   let total = query.length;
    let chunk_size = query.chunk_size.unwrap_or(8192).max(1); // At least 1

    let body_stream: Pin<Box<dyn Stream<Item = Result<web::Bytes, actix_web::Error>>>> =
        Box::pin(stream::unfold(0, move |sent| {
            let total = total;
            let chunk_size = chunk_size;
            async move {
                let remaining = total.saturating_sub(sent);
                if remaining == 0 {
                    return None;
                }

                let current_chunk_size = remaining.min(chunk_size);
                let chunk = web::Bytes::from(vec![b'a'; current_chunk_size]);
                Some((Ok(chunk), sent + current_chunk_size))
            }
        }));

    HttpResponse::Ok()
        .insert_header((header::CONTENT_TYPE, "text/plain"))
        .streaming(body_stream)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/generate/{length}", web::get().to(generate))
            .route("/generate_chunk", web::get().to(generate_chunk))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}