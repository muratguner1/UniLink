from neo4j import GraphDatabase, AsyncGraphDatabase
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv

load_dotenv()

URI      = os.getenv("NEO4J_URI")
USERNAME = os.getenv("NEO4J_USERNAME")
PASSWORD = os.getenv("NEO4J_PASSWORD")

_driver = None

async def get_driver():
    global _driver
    if _driver is None:
        _driver = AsyncGraphDatabase.driver(URI, auth=(USERNAME, PASSWORD))
        await _driver.verify_connectivity()
    return _driver

async def close_driver():
    global _driver
    if _driver:
        await _driver.close()
        _driver = None

@asynccontextmanager
async def get_session():
    """
    Her endpoint çağrısında yeni bir session açar, işlem bitince kapatır.
    'async with get_session() as session:' şeklinde kullan.
    """
    driver = await get_driver()
    session = driver.session()
    try:
        yield session
    finally:
        await session.close()
