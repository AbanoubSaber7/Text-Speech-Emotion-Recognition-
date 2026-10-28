import os
from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, StringConstraints
from transformers import pipeline

MODEL_NAME = "j-hartmann/emotion-english-distilroberta-base"


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Loading emotion model...")
    app.state.classifier = pipeline(
        "text-classification",
        model=MODEL_NAME,
        top_k=None,
        device=-1,
    )
    print("Emotion model loaded successfully!")
    yield


app = FastAPI(
    title="Current Mood API",
    description=(
        "Classifies emotions expressed in English text. "
        "It is not a mental-health diagnostic tool."
    ),
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        origin.strip()
        for origin in os.getenv("CORS_ORIGINS", "").split(",")
        if origin.strip()
    ],
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=False,
    allow_methods=["POST"],
    allow_headers=["Content-Type"],
)


class TextRequest(BaseModel):
    text: Annotated[
        str,
        StringConstraints(strip_whitespace=True, min_length=1, max_length=2000),
    ]


class EmotionScore(BaseModel):
    label: str
    confidence: float


class AnalysisResponse(BaseModel):
    text: str
    emotion: str
    confidence: float
    all_emotions: list[EmotionScore]


@app.post("/analyze", response_model=AnalysisResponse)
def analyze_text(payload: TextRequest, request: Request) -> AnalysisResponse:
    predictions = request.app.state.classifier(payload.text)
    if predictions and isinstance(predictions[0], list):
        predictions = predictions[0]

    emotions = [
        EmotionScore(
            label=prediction["label"].lower(),
            confidence=round(float(prediction["score"]) * 100, 2),
        )
        for prediction in predictions
    ]
    emotions.sort(key=lambda item: item.confidence, reverse=True)

    highest = emotions[0]
    return AnalysisResponse(
        text=payload.text,
        emotion=highest.label,
        confidence=highest.confidence,
        all_emotions=emotions,
    )
