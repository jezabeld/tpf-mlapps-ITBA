"""Data model definition."""

import utils.db_connections as db
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class DepDelay(Base):
    """Departure delay data model."""

    __tablename__ = "dep_delay" #nombre de la tabla en la db 
    origin = Column(String, primary_key=True)
    date = Column(String, primary_key=True) 
    num_flights = Column(Integer)
    dep_delay= Column(Float)
    del_scaled = Column(Float)
    outlier = Column(Integer)

    def __init__(self, origin, date, num_flights, dep_delay, del_scaled, outlier):
        self.origin = origin
        self.date = date
        self.num_flights = num_flights
        self.dep_delay = dep_delay
        self.del_scaled = del_scaled
        self.outlier = outlier

    def __repr__(self):
        return f"<DepDelay(origin='{self.origin}', date='{self.date}', ...)>"

    def __str__(self):
        return f"{self.origin} {self.date}: ${self.num_flights}"

    def get_keys(self):
        return {'origin': self.origin, 'date': self.date}

