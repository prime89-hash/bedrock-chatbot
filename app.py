import boto3
import streamlit as st
import os

# Create Bedrock client
bedrock_client = boto3.client(
    service_name="bedrock-runtime",
    region_name=os.getenv("BEDROCK_REGION", "us-west-2")
)

# Model ID (Claude Sonnet 4 Inference Profile)
model_id = "us.anthropic.claude-sonnet-4-20250514-v1:0"

# Function to generate response from Bedrock
def query_bedrock(language, freeform_text):
    system_message = f"You are a helpful chatbot. Respond in {language}."
    
    try:
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
    except Exception as e:
        return f"Error: {str(e)}"

# Health check endpoint for ALB
if st.query_params.get("health") == "check":
    st.write("OK")
    st.stop()

# Streamlit UI
st.set_page_config(page_title="Secure Bedrock Chatbot", page_icon="🤖")
st.title("🤖 Secure Bedrock Chatbot")
st.markdown("*Powered by Claude Sonnet 4 with ALB Cognito Authentication*")

# Sidebar configuration
with st.sidebar:
    st.header("Configuration")
    language = st.selectbox("Response Language", ["English", "Spanish", "French"])
    st.markdown("---")
    st.markdown("**Security Features:**")
    st.markdown("✅ ALB Cognito Authentication")
    st.markdown("✅ HTTPS Encryption")
    st.markdown("✅ Private Network")
    st.markdown("✅ VPC Endpoints")
    st.markdown("✅ IAM Role Restrictions")

# Main chat interface
question = st.text_area("Ask me anything:", placeholder="Enter your question here...", height=100)

if st.button("Send", type="primary"):
    if question.strip():
        with st.spinner("Thinking..."):
            response = query_bedrock(language.lower(), question)
        
        st.success("Response:")
        st.write(response)
    else:
        st.error("Please enter a question.")
