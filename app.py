import boto3
import json
import streamlit as st



# Create Bedrock client
bedrock_client = boto3.client(
    service_name="bedrock-runtime",
    region_name="us-west-2"
)

# Model ID (Amazon Titan)
model_id = "amazon.titan-text-express-v1"

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
        body=json.dumps(body),
        modelId=model_id,
        accept="application/json",
        contentType="application/json"
    )

    result = json.loads(response['body'].read())
    return result['results'][0]['outputText']

# Streamlit UI
st.title("Bedrock Chatbot ASK ME")

language = st.sidebar.selectbox("Language", ["english", "spanish"])
freeform_text = st.sidebar.text_area("What is your question?", max_chars=200)

#Submit Button

if st.sidebar.button("Submit"):
    if freeform_text.strip()!="":
        with st.spinner("thinking..."):
            output = query_bedrock(language, freeform_text)
        st.success("Done!")
        st.write(output)
    else:
        st.error("Please enter a question.")

