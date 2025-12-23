"""
PM Internship Scheme - Flask Backend
Government of India
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json
from recommendation_engine import RecommendationEngine

app = Flask(__name__)
CORS(app)

# Initialize recommendation engine
engine = RecommendationEngine()

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "message": "PM Internship API is running",
        "version": "1.0.0"
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
        recommendations = engine.recommend(
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

@app.route('/api/sectors', methods=['GET'])
def get_sectors():
    """Get available sectors"""
    sectors = [
        "IT & Software",
        "Manufacturing",
        "Marketing & Sales",
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
    app.run(debug=True, host='0.0.0.0', port=5000)