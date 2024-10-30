# LLM tooling

- [Hugging Face RAG Transformer](https://huggingface.co/blog/ray-rag): Provides a comprehensive collection of pre-trained models, including RAG.
- [Vellum.ai](https://www.vellum.ai/): Vellum is a development platform for building LLM apps with tools for prompt engineering, semantic search, version control, testing, and monitoring.
- [Elasticsearch](https://cookbook.openai.com/examples/vector_databases/elasticsearch/elasticsearch-retrieval-augmented-generation): A A powerful search engine, ideal for the retrieval phase in RAG.
- [FAISS (Facebook AI Similarity Search)](https://engineering.fb.com/2017/03/29/data-infrastructure/faiss-a-library-for-efficient-similarity-search/): Efficient for similarity search in large datasets, useful for retrieval.
- [Dense Passage Retrieval (DPR)](https://huggingface.co/docs/transformers/model_doc/dpr): Optimized for retrieving relevant passages from extensive text corpora.
- [Haystack](https://haystack.deepset.ai/tutorials/07_rag_generator): An NLP framework that simplifies the building of search systems, integrating well with Elasticsearch and DPR.
- [PyTorch](https://huggingface.co/docs/transformers/model_doc/rag) and [TensorFlow](https://huggingface.co/docs/transformers/model_doc/rag): Foundational deep learning frameworks for developing and training RAG models.
- [ColBERT](https://medium.com/@zz1409/colbert-a-late-interaction-model-for-semantic-search-da00f052d30e): A BERT-based ranking model for high-precision retrieval.
- [Apache Solr](https://solr.apache.org/): An open-source search platform, an alternative to Elasticsearch for retrieval.
- [Pinecone](https://www.pinecone.io/learn/fast-retrieval-augmented-generation/): A scalable vector database optimized for machine learning applications.Ideal for vector-based similarity search, playing a crucial role in the retrieval phase of RAG.
- [Langchain](https://www.langchain.com/): A toolkit designed to integrate language models with external knowledge sources. Bridges the gap between language models and external data, useful for both the retrieval and augmentation stages in RAG.
- [LlamaIndex](https://www.llamaindex.ai/): Specializes in indexing and retrieving information, aiding the retrieval stage of RAG. Facilitates efficient indexing, making it suitable for applications requiring rapid and relevant data retrieval.

## LangChain vs LlamaIndex

Another big choice is with Langchain and LlamaIndex. Datacamp article [LangChain vs LlamaIndex: A Detailed Comparison](https://www.datacamp.com/blog/langchain-vs-llamaindex) provides a good overview of which works best based on your use case. They write:

| Feature | Langchain | LlamaIndex |
| - | - | - |
| Data indexing | LangChain provides a modular and customizable approach to data indexing with complex chains of operations, integrating multiple tools and LLM calls. | LlamaIndex transforms various types of data, such as unstructured text documents and structured database records, into numerical embeddings that capture their semantic meaning. |
| Retrieval algorithms | LangChain integrates retrieval algorithms with LLMs to produce context-aware outputs. LangChain can dynamically retrieve and process relevant information based on the context of the user’s input, which is useful for interactive applications like chatbots.  | LlamaIndex is optimized for retrieval, using algorithms to rank documents based on their semantic similarity to perform a query. |
| Customization | LangChain, however, provides extensive customization options. It supports the creation of complex workflows for highly tailored applications with specific requirements. | LlamaIndex offers limited customization focused on indexing and retrieval tasks. Its design is optimized for these specific functions, providing high accuracy. |
| Context retention | LangChain excels in context retention, which is crucial for applications where retaining information from previous interactions and coherent and contextually relevant responses over long conversations are crucial. | LlamaIndex provides basic context retention capabilities suitable for simple search and retrieval tasks. It can manage the context of queries to some extent but is not designed to maintain long interactions. |
| Use cases | LangChain is better suited for applications requiring complex interaction and content generation, such as customer support, code documentation, and various NLP tasks. | LlamaIndex is ideal for internal search systems, knowledge management, and enterprise solutions where accurate information retrieval is critical. |
| Performance | LangChain is efficient in handling complex data structures that can operate inside its modular architecture for sophisticated workflows. | LlamaIndex is optimized for speed and accuracy; the fast retrieval of relevant information. Optimization is crucial for handling large volumes of data and quick responses. |
| Lifecycle management | LangChain offers evaluation suite, LangSmith, tools for testing, debugging, and optimizing LLM applications, ensuring that applications perform well under real-world conditions. | LlamaIndex integrates with debugging and monitoring tools to facilitate lifecycle management. Integration helps tracking the performance and reliability of applications by providing insights and tools for troubleshooting. |

## References

- [RAG 101: What is RAG and why does it matter?](https://codingscape.com/blog/rag-101-what-is-rag-and-why-does-it-matter)