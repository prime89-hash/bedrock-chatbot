import boto3
import streamlit as st



# Create Bedrock client
bedrock_client = boto3.client(
    service_name="bedrock-runtime",
    region_name="us-west-2"
)

# Model ID (Claude 3.5 Sonnet v2)
model_id = "anthropic.claude-3-5-sonnet-20241022-v2:0"

# Function to generate response from Bedrock
def query_bedrock(language, freeform_text):
    system_message = f"You are a chatbot. You are in {language}."
    
    response = bedrock_client.converse(
        modelId=model_id,
        messages=[
            {
                "role": "user",
                "content": [{"text": freeform_text}]
            }
        ],
        system=[{"text": system_message}],
        inferenceConfig={
            "temperature": 0.9,
            "maxTokens": 2000,
            "topP": 1
        }
    )
    
    return response['output']['message']['content'][0]['text']

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

