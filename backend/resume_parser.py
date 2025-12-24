"""
Resume Parser - Extract Skills using NLP
Lightweight approach for government deployment
"""

import re
import json
from typing import List, Dict
import os

class ResumeParser:
    def __init__(self):
        self.skill_database = self._load_skill_database()
        
    def _load_skill_database(self) -> Dict:
        """Load skill patterns for extraction"""
        return {
            # Technical Skills
            "programming": [
                "python", "java", "javascript", "c++", "c#", "php", "ruby", 
                "swift", "kotlin", "golang", "rust", "r programming"
            ],
            "web": [
                "html", "css", "react", "angular", "vue", "node.js", "django", 
                "flask", "spring boot", "express"
            ],
            "data": [
                "sql", "mysql", "mongodb", "postgresql", "oracle", "excel", 
                "data analysis", "data entry", "database"
            ],
            "design": [
                "photoshop", "illustrator", "figma", "canva", "corel draw",
                "autocad", "3d modeling", "ui/ux", "graphic design"
            ],
            "digital": [
                "social media", "seo", "sem", "google ads", "facebook ads",
                "content writing", "copywriting", "email marketing"
            ],
            
            # Soft Skills
            "communication": [
                "communication", "presentation", "public speaking", 
                "negotiation", "interpersonal"
            ],
            "management": [
                "leadership", "team management", "project management",
                "time management", "organization", "planning"
            ],
            "analytical": [
                "problem solving", "critical thinking", "analytical",
                "research", "decision making"
            ],
            
            # Languages
            "languages": [
                "english", "hindi", "tamil", "telugu", "bengali", "marathi",
                "gujarati", "kannada", "malayalam", "punjabi", "urdu"
            ],
            
            # Office & Basic
            "office": [
                "ms office", "microsoft office", "word", "excel", "powerpoint",
                "outlook", "google sheets", "google docs"
            ],
            
            # Domain Specific
            "finance": [
                "accounting", "tally", "gst", "taxation", "bookkeeping",
                "financial analysis", "auditing"
            ],
            "sales": [
                "sales", "marketing", "customer service", "crm", "cold calling",
                "business development"
            ],
            "education": [
                "teaching", "training", "tutoring", "curriculum development",
                "classroom management"
            ],
            "healthcare": [
                "nursing", "patient care", "first aid", "medical terminology",
                "pharmacy"
            ],
            "manual": [
                "manual work", "mechanical", "electrical", "plumbing",
                "carpentry", "welding", "driving"
            ]
        }
    
    def parse_text(self, text: str) -> Dict:
        """
        Parse resume text and extract information
        
        Args:
            text: Resume text content
            
        Returns:
            Dict with extracted skills, education, etc.
        """
        text_lower = text.lower()
        
        # Extract skills
        extracted_skills = self._extract_skills(text_lower)
        
        # Extract education
        education = self._extract_education(text)
        
        # Extract contact info (basic)
        email = self._extract_email(text)
        phone = self._extract_phone(text)
        
        return {
            "skills": extracted_skills,
            "education": education,
            "email": email,
            "phone": phone,
            "confidence": self._calculate_confidence(extracted_skills, education)
        }
    
    def _extract_skills(self, text: str) -> List[str]:
        """Extract skills from text using pattern matching"""
        found_skills = set()
        
        # Check each skill category
        for category, skills_list in self.skill_database.items():
            for skill in skills_list:
                # Use word boundaries for better matching
                pattern = r'\b' + re.escape(skill) + r'\b'
                if re.search(pattern, text, re.IGNORECASE):
                    # Capitalize properly
                    found_skills.add(skill.title())
        
        # Convert to standardized names (matching our app's skill list)
        standardized = self._standardize_skills(found_skills)
        
        return sorted(list(standardized))[:15]  # Return top 15 skills
    
    def _standardize_skills(self, skills: set) -> set:
        """Map extracted skills to standard skill names used in app"""
        skill_mapping = {
            # Programming
            "Python": "Python",
            "Java": "Java",
            "Javascript": "JavaScript",
            
            # Communication
            "Communication": "Communication",
            "Presentation": "Communication",
            "Public Speaking": "Communication",
            
            # Languages
            "English": "English",
            "Hindi": "Hindi",
            "Tamil": "Tamil",
            "Telugu": "Telugu",
            "Bengali": "Bengali",
            "Marathi": "Marathi",
            "Gujarati": "Gujarati",
            "Kannada": "Kannada",
            
            # Office
            "Ms Office": "MS Office",
            "Microsoft Office": "MS Office",
            "Excel": "MS Office",
            "Word": "MS Office",
            
            # Other
            "Sales": "Sales",
            "Customer Service": "Customer Service",
            "Data Entry": "Data Entry",
            "Social Media": "Social Media",
            "Accounting": "Accounting",
            "Teaching": "Teaching",
            "Manual Work": "Manual Work",
            "Problem Solving": "Problem Solving",
            "Research": "Research",
            "Photoshop": "Photoshop",
            "Creativity": "Creativity",
            "Quality Control": "Quality Control",
            "Organization": "Organization",
            "Networking": "Networking",
            "Writing": "Writing",
            "Video Editing": "Video Editing",
            "Autocad": "AutoCAD",
            "Engineering": "Engineering",
            "Social Work": "Social Work",
            "Mechanical Skills": "Mechanical Skills",
            "Electrical Work": "Electrical Work",
            "Data Analysis": "Data Analysis"
        }
        
        standardized = set()
        for skill in skills:
            for key, value in skill_mapping.items():
                if skill.lower() == key.lower():
                    standardized.add(value)
                    break
        
        return standardized
    
    def _extract_education(self, text: str) -> str:
        """Extract highest education level"""
        education_patterns = {
            "Master's Degree": [
                r'master', r'mba', r'mca', r'msc', r'm\.tech', r'm\.sc',
                r'post graduate', r'pg'
            ],
            "Bachelor's Degree": [
                r'bachelor', r'btech', r'b\.tech', r'be', r'b\.e', r'bca',
                r'bcom', r'bsc', r'ba', r'graduate', r'graduation'
            ],
            "Diploma": [
                r'diploma', r'polytechnic', r'iti'
            ],
            "12th Pass": [
                r'12th', r'12 th', r'xii', r'higher secondary', r'intermediate',
                r'\+2', r'hsc'
            ],
            "10th Pass": [
                r'10th', r'10 th', r'x\b', r'matriculation', r'secondary',
                r'ssc'
            ]
        }
        
        text_lower = text.lower()
        
        # Check in order of highest to lowest
        for education, patterns in education_patterns.items():
            for pattern in patterns:
                if re.search(pattern, text_lower):
                    return education
        
        return "12th Pass"  # Default assumption
    
    def _extract_email(self, text: str) -> str:
        """Extract email address"""
        email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
        match = re.search(email_pattern, text)
        return match.group(0) if match else ""
    
    def _extract_phone(self, text: str) -> str:
        """Extract Indian phone number"""
        phone_patterns = [
            r'\+91[\s-]?\d{10}',  # +91 format
            r'0\d{10}',            # 0 prefix
            r'\d{10}'              # Plain 10 digits
        ]
        
        for pattern in phone_patterns:
            match = re.search(pattern, text)
            if match:
                return match.group(0)
        
        return ""
    
    def _calculate_confidence(self, skills: List[str], education: str) -> float:
        """Calculate parsing confidence score"""
        confidence = 0.0
        
        # Skills found
        if len(skills) > 0:
            confidence += 40.0
        if len(skills) >= 3:
            confidence += 20.0
        
        # Education found
        if education != "12th Pass":  # Not default
            confidence += 40.0
        
        return min(confidence, 100.0)


# PDF/DOCX Utilities
def extract_text_from_pdf(file_content: bytes) -> str:
    """
    Extract text from PDF file
    Requires: pdfplumber or PyPDF2
    """
    try:
        import pdfplumber
        import io
        
        # Validate file content
        if not file_content or len(file_content) < 100:
            raise ValueError("PDF file is too small or empty")
        
        text = ""
        with pdfplumber.open(io.BytesIO(file_content)) as pdf:
            # Check if PDF has pages
            if not pdf.pages:
                raise ValueError("PDF has no pages")
            
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        
        # Validate extracted text
        if not text or len(text.strip()) < 10:
            raise ValueError("Could not extract text from PDF. The PDF might be image-based or corrupted.")
        
        return text
    except ImportError:
        raise Exception("pdfplumber not installed. Run: pip install pdfplumber")
    except ValueError as e:
        raise Exception(str(e))
    except Exception as e:
        # More specific error messages
        error_msg = str(e).lower()
        if "password" in error_msg or "encrypted" in error_msg:
            raise Exception("PDF is password protected or encrypted")
        elif "damaged" in error_msg or "corrupt" in error_msg:
            raise Exception("PDF file appears to be corrupted")
        else:
            raise Exception(f"Could not parse PDF: {str(e)}")


def extract_text_from_docx(file_content: bytes) -> str:
    """
    Extract text from DOCX file
    Requires: python-docx
    """
    try:
        import docx
        import io
        
        # Validate file content
        if not file_content or len(file_content) < 100:
            raise ValueError("DOCX file is too small or empty")
        
        doc = docx.Document(io.BytesIO(file_content))
        text = "\n".join([paragraph.text for paragraph in doc.paragraphs])
        
        # Validate extracted text
        if not text or len(text.strip()) < 10:
            raise ValueError("Could not extract text from DOCX. The file might be empty or corrupted.")
        
        return text
    except ImportError:
        raise Exception("python-docx not installed. Run: pip install python-docx")
    except ValueError as e:
        raise Exception(str(e))
    except Exception as e:
        raise Exception(f"Could not parse DOCX: {str(e)}")


# Example usage
if __name__ == "__main__":
    parser = ResumeParser()
    
    # Test with sample resume text
    sample_resume = """
    JOHN DOE
    john.doe@email.com | +91 9876543210
    
    EDUCATION
    Bachelor of Technology (B.Tech) in Computer Science
    XYZ University, 2020-2024
    
    SKILLS
    - Programming: Python, Java, JavaScript
    - Web Development: HTML, CSS, React
    - Database: MySQL, MongoDB
    - Tools: MS Office, Git
    - Languages: English, Hindi, Tamil
    - Soft Skills: Communication, Team Management, Problem Solving
    
    EXPERIENCE
    Software Intern at ABC Company
    - Developed web applications using Python and Django
    - Worked on data analysis projects
    """
    
    result = parser.parse_text(sample_resume)
    
    print("Extracted Information:")
    print(f"Skills: {result['skills']}")
    print(f"Education: {result['education']}")
    print(f"Email: {result['email']}")
    print(f"Phone: {result['phone']}")
    print(f"Confidence: {result['confidence']}%")