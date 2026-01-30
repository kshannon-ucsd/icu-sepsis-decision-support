from fastapi import APIRouter

from app.controllers.management import router as management_router
from app.controllers.patient import router as patient_router
from app.controllers.prediction import router as prediction_router


api_router = APIRouter()

# Layered API surfaces (placeholders for now)
api_router.include_router(management_router, prefix="/management", tags=["management"])
api_router.include_router(patient_router, prefix="/patient", tags=["patient"])
api_router.include_router(prediction_router, prefix="/prediction", tags=["prediction"])
