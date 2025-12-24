"""
PM Internship Scheme - Flask Backend with Resume Upload
Government of India
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json
from recommendation_engine import RecommendationEngine
from resume_parser import ResumeParser, extract_text_from_pdf, extract_text_from_docx

app = Flask(__name__)
CORS(app)

# Initialize engines
recommendation_engine = RecommendationEngine()
resume_parser = ResumeParser()

# File upload configuration
ALLOWED_EXTENSIONS = {'pdf', 'docx', 'txt'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "message": "PM Internship API is running",
        "version": "2.0.0",
        "features": ["recommendations", "resume_parsing", "multi_language"]
    })

@app.route('/api/recommend', methods=['POST'])
def get_recommendations():
    """
    Get internship recommendations
    
    Expected JSON:
    {
        "education": "Bachelor's Degree",
        "skills": ["Python", "Communication"],
        "sector": "IT",
        "location": "Delhi"
    }
    """
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['education', 'skills', 'sector', 'location']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    "error": f"Missing required field: {field}"
                }), 400
        
        # Get recommendations
        recommendations = recommendation_engine.recommend(
            education=data['education'],
            skills=data['skills'],
            sector=data['sector'],
            location=data['location']
        )
        
        return jsonify({
            "success": True,
            "count": len(recommendations),
            "recommendations": recommendations
        })
    
    except Exception as e:
        return jsonify({
            "error": str(e),
            "success": False
        }), 500

@app.route('/api/resume/upload', methods=['POST'])
def upload_resume():
    """
    Upload and parse resume
    
    Returns extracted skills and education
    """
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({
                "error": "No file provided",
                "success": False
            }), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({
                "error": "Empty filename",
                "success": False
            }), 400
        
        if not allowed_file(file.filename):
            return jsonify({
                "error": "Invalid file type. Allowed: PDF, DOCX, TXT",
                "success": False
            }), 400
        
        # Read file content
        file_content = file.read()
        
        # Check file size
        if len(file_content) > MAX_FILE_SIZE:
            return jsonify({
                "error": "File too large. Maximum size: 5MB",
                "success": False
            }), 400
        
        # Extract text based on file type
        filename = file.filename.lower()
        text = None
        
        try:
            if filename.endswith('.pdf'):
                text = extract_text_from_pdf(file_content)
            elif filename.endswith('.docx'):
                text = extract_text_from_docx(file_content)
            elif filename.endswith('.txt'):
                text = file_content.decode('utf-8', errors='ignore')
            else:
                return jsonify({
                    "error": "Unsupported file format",
                    "success": False
                }), 400
        except Exception as e:
            # Handle parsing errors specifically
            error_message = str(e)
            return jsonify({
                "error": error_message,
                "success": False,
                "details": "Failed to extract text from file"
            }), 400
        
        # Validate extracted text
        if not text or len(text.strip()) < 10:
            return jsonify({
                "error": "Could not extract meaningful text from the file",
                "success": False,
                "details": "The file might be empty, image-based, or corrupted"
            }), 400
        
        # Parse resume
        try:
            parsed_data = resume_parser.parse_text(text)
        except Exception as e:
            return jsonify({
                "error": f"Failed to parse resume: {str(e)}",
                "success": False
            }), 500
        
        return jsonify({
            "success": True,
            "data": {
                "skills": parsed_data['skills'],
                "education": parsed_data['education'],
                "email": parsed_data['email'],
                "phone": parsed_data['phone'],
                "confidence": parsed_data['confidence']
            },
            "message": f"Resume parsed successfully. Found {len(parsed_data['skills'])} skills."
        })
    
    except Exception as e:
        return jsonify({
            "error": f"Unexpected error: {str(e)}",
            "success": False
        }), 500

@app.route('/api/resume/parse-text', methods=['POST'])
def parse_resume_text():
    """
    Parse resume from text input (for mobile copy-paste)
    
    Expected JSON:
    {
        "text": "Resume text content..."
    }
    """
    try:
        data = request.json
        
        if 'text' not in data:
            return jsonify({
                "error": "No text provided",
                "success": False
            }), 400
        
        text = data['text']
        
        if len(text.strip()) < 50:
            return jsonify({
                "error": "Text too short. Please provide complete resume.",
                "success": False
            }), 400
        
        # Parse resume
        parsed_data = resume_parser.parse_text(text)
        
        return jsonify({
            "success": True,
            "data": {
                "skills": parsed_data['skills'],
                "education": parsed_data['education'],
                "confidence": parsed_data['confidence']
            },
            "message": f"Resume parsed successfully. Found {len(parsed_data['skills'])} skills."
        })
    
    except Exception as e:
        return jsonify({
            "error": str(e),
            "success": False
        }), 500

@app.route('/api/sectors', methods=['GET'])
def get_sectors():
    """Get available sectors"""
    # Load from extended JSON
    import os
    data_path = os.path.join(os.path.dirname(__file__), 'data', 'internships_extended.json')
    
    try:
        with open(data_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            sectors = data.get('sectors', [])
    except:
        # Fallback to hardcoded list
        sectors = [
            "IT & Software",
            "Marketing & Sales",
            "Manufacturing",
            "Finance & Banking",
            "Healthcare",
            "Education",
            "Agriculture",
            "Retail",
            "Hospitality",
            "Government"
        ]
    
    return jsonify({"sectors": sectors})

@app.route('/api/skills', methods=['GET'])
def get_skills():
    """Get common skills"""
    import os
    data_path = os.path.join(os.path.dirname(__file__), 'data', 'internships_extended.json')
    
    try:
        with open(data_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            skills = data.get('skills', [])
    except:
        # Fallback
        skills = [
            "Communication",
            "MS Office",
            "English",
            "Hindi",
            "Python",
            "Java",
            "Sales",
            "Customer Service",
            "Data Entry",
            "Social Media",
            "Accounting",
            "Teaching",
            "Manual Work",
            "Driving"
        ]
    
    return jsonify({"skills": skills})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
