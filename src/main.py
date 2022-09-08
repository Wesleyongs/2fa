import datetime as dt
from typing import List

import uvicorn
from fastapi import Depends, FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

# local variables
from urlconversion import crud
from urlconversion import schemas
from urlconversion.database import Base, SessionLocal, engine

Base.metadata.create_all(bind=engine)

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/UrlConversion/", response_model=schemas.UrlConversion, tags=['UrlConversion'])
def UrlConversion(input_url, db: Session = Depends(get_db)):
    return crud.create_url_conversion(db=db, input_url=input_url)

@app.get("/UrlConversion/", response_model=List[schemas.UrlConversion], tags=['UrlConversion'])
def get_converted_url(db: Session = Depends(get_db)):
    return crud.get_url_conversions(db)

@app.delete("/UrlConversion/", response_model=str, tags=['UrlConversion'])
def delete_all_url_conversions(db: Session = Depends(get_db)):
    return crud.delete_all_url_conversions(db)
    
if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
