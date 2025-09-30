# Import necessary libraries
import boto3
import json
import streamlit as st
from botocore.config import Config

# Configure boto3 to use a specific retry strategy
boto_config = Config(
    retries={
        'max_attempts': 10,
        'mode': 'standard'
    },
    connect_timeout=10,
    read_timeout=60
)

# Create Bedrock client
bedrock_client = boto3.client(
    service_name="bedrock-runtime",
    region_name="us-west-2",  # Change if your model is in another region
    config=boto_config
)

# Model ID (Claude Sonnet 4)
model_id = "anthropic.claude-sonnet-4-20250514-v1:0"

# Function to generate response from Bedrock
def query_bedrock(language, freeform_text):
    prompt = f"You are a chatbot. You are in {language}.\n\n{freeform_text}"

    body = {
        "inputText": prompt,
        "textGenerationConfig": {
            "temperature": 0.9,
            "maxTokenCount": 2000,
            "topP": 1,
            "stopSequences": []
        }
    }

    response = bedrock_client.invoke_model(
        modelId=model_id,
        body=json.dumps(body),
        contentType="application/json",
        accept="application/json"
    )

    result = json.loads(response['body'].read())
    return result['results'][0]['outputText']

# Streamlit UI
st.title("Bedrock Chatbot ASK ME")

language = st.sidebar.selectbox("Language", ["english", "spanish"])
freeform_text = st.sidebar.text_area("What is your question?", max_chars=200)

# Submit Button
if st.sidebar.button("Submit"):
    if freeform_text.strip() != "":
        with st.spinner("Thinking..."):
            output = query_bedrock(language, freeform_text)
        st.success("Done!")
        st.write(output)
    else:
        st.error("Please enter a question.")
