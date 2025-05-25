#!/usr/bin/python3

from langchain.vectorstores import Chroma
from langchain.embeddings import OllamaEmbeddings
from langchain.chains import RetrievalQA
from langchain.llms import Ollama
from langchain.chains.qa_with_sources import load_qa_with_sources_chain

# Setup
PERSIST_DIRECTORY = "./vector_db"
EMBED_MODEL = "nomic-embed-text"
LLM_MODEL = "mistral"

# Load embedding and vector store
embedding = OllamaEmbeddings(model=EMBED_MODEL)
vectorstore = Chroma(persist_directory=PERSIST_DIRECTORY, embedding_function=embedding)
retriever = vectorstore.as_retriever(search_kwargs={"k": 4})  # Adjust k as needed
llm = Ollama(model=LLM_MODEL)

# Use chain that returns both answer and sources
qa_chain = load_qa_with_sources_chain(llm=llm)

# Sample Questions
sample_questions = [
    "What is cognetics and how is it different from traditional cognitive science?",
    "Summarize the role of feedback loops in human-computer interaction.",
    "What are some key ideas from Donald Norman mentioned in the documents?",
    "How does the concept of affordance relate to design and perception?"
]

print("\n📚 Vector DB loaded. Ask anything! Type 'exit' to quit.")
print("\n💡 Sample questions you can try:")
for q in sample_questions:
    print(f"  - {q}")
print("")

# Interactive Query Loop
while True:
    query = input("🔍 Your question: ")
    if query.lower() in ("exit", "quit"):
        break

    docs = retriever.get_relevant_documents(query)
    result = qa_chain({"input_documents": docs, "question": query}, return_only_outputs=True)

    print("\n🤖 Answer:\n", result["output_text"])
    print("\n📄 Sources:\n")
    for i, doc in enumerate(docs, 1):
        source = doc.metadata.get("source", "Unknown file")
        print(f"[{i}] Source: {source}\n{doc.page_content[:500]}...\n")  # Trim long output
    print("-" * 80)

