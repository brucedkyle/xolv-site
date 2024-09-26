from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

# Load data
documents = SimpleDirectoryReader("docs").load_data()

# Build the index
index = VectorStoreIndex.from_documents(documents)

# Query the index
query_engine = index.as_query_engine()
response = query_engine.query("Who won the war of the worlds?")
print(response)
response = query_engine.query("What was the outcome of the war of the worlds?")
print(response)
response = query_engine.query("What happens to the Martians in the end?")
print(response)

summarization_prompt = f"""You are a blog post summarization bot.
Your take a book and write a summary of it.
The summary is intended to hook a reader into entice them to read it.
"""
response = index.query(summarization_prompt)
print(response.response)