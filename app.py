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

# Simple authentication function
def check_password():
    """Returns `True` if the user had the correct password."""
    
    def password_entered():
        """Checks whether a password entered by the user is correct."""
        if st.session_state["password"] == "SecurePass123!":
            st.session_state["password_correct"] = True
            del st.session_state["password"]  # don't store password
        else:
            st.session_state["password_correct"] = False

    if "password_correct" not in st.session_state:
        # First run, show input for password.
        st.text_input(
            "Password", type="password", on_change=password_entered, key="password"
        )
        st.write("*Please enter the password to access the chatbot.*")
        return False
    elif not st.session_state["password_correct"]:
        # Password not correct, show input + error.
        st.text_input(
            "Password", type="password", on_change=password_entered, key="password"
        )
        st.error("😕 Password incorrect")
        return False
    else:
        # Password correct.
        return True

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

# Main application
if check_password():
    # Streamlit UI
    st.set_page_config(page_title="Secure Bedrock Chatbot", page_icon="🤖")
    st.title("🤖 Secure Bedrock Chatbot")
    st.markdown("*Powered by Claude Sonnet 4 with enterprise security*")

    # Sidebar configuration
    with st.sidebar:
        st.header("Configuration")
        language = st.selectbox("Response Language", ["English", "Spanish", "French"])
        st.markdown("---")
        st.markdown("**Security Features:**")
        st.markdown("✅ Password Authentication")
        st.markdown("✅ Private Network")
        st.markdown("✅ VPC Endpoints")
        st.markdown("✅ IAM Role Restrictions")
        
        if st.button("Logout"):
            st.session_state["password_correct"] = False
            st.rerun()

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
