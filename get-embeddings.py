#!/usr/bin/python3

import os
from langchain_community.document_loaders import (
    UnstructuredMarkdownLoader, TextLoader, PyPDFLoader
)
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import OllamaEmbeddings
from langchain_community.vectorstores import Chroma

# Configuration
BASE_DIR = os.getcwd()
VECTOR_DIR = "./vector_db"
EMBED_MODEL = "nomic-embed-text"

# File extension to loader mapping
EXTENSION_LOADERS = {
    ".md": UnstructuredMarkdownLoader,
    ".txt": TextLoader,
    ".py": TextLoader,
    ".ipynb": TextLoader,
    ".pdf": PyPDFLoader,
}

documents = []

# Walk the directory and load files
for root, dirs, files in os.walk(BASE_DIR):
    for filename in files:
        filepath = os.path.join(root, filename)
        ext = os.path.splitext(filename)[1].lower()
        loader_class = EXTENSION_LOADERS.get(ext)
        if loader_class:
            try:
                loader = loader_class(filepath)
                docs = loader.load()
                documents.extend(docs)
                print(f"Loaded: {filepath}")
            except Exception as e:
                print(f"Failed to load {filepath}: {e}")

print(f"Total loaded documents: {len(documents)}")

# Split into chunks
splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
chunks = splitter.split_documents(documents)
print(f"Split into {len(chunks)} chunks.")

# Generate embeddings
embedder = OllamaEmbeddings(model=EMBED_MODEL)
vectorstore = Chroma.from_documents(chunks, embedding=embedder, persist_directory=VECTOR_DIR)
vectorstore.persist()

print("Embeddings generated and stored.")
