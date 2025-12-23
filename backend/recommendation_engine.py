"""
Explainable AI Recommendation Engine
Uses transparent scoring - NO black-box models
"""

import json
from typing import List, Dict
import os

class RecommendationEngine:
    def __init__(self):
        self.internships = self._load_internships()
        
        # Scoring weights (transparent and explainable)
        self.weights = {
            'skill_match': 0.40,      # 40% - Most important
            'sector_match': 0.30,     # 30% - Medium importance
            'location_match': 0.20,   # 20% - Medium importance
            'education_match': 0.10   # 10% - Low importance
        }
    
    def _load_internships(self) -> List[Dict]:
        """Load internship data from JSON"""
        data_path = os.path.join(os.path.dirname(__file__), 'data', 'internships.json')
        with open(data_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data['internships']
    
    def _calculate_skill_match(self, user_skills: List[str], internship_skills: List[str]) -> float:
        """Calculate skill matching score (0-100)"""
        if not user_skills or not internship_skills:
            return 0.0
        
        # Convert to lowercase for case-insensitive matching
        user_skills_lower = [s.lower().strip() for s in user_skills]
        internship_skills_lower = [s.lower().strip() for s in internship_skills]
        
        # Count matches
        matches = sum(1 for skill in user_skills_lower if skill in internship_skills_lower)
        
        # Calculate percentage
        score = (matches / len(internship_skills_lower)) * 100
        return min(score, 100)  # Cap at 100
    
    def _calculate_sector_match(self, user_sector: str, internship_sector: str) -> float:
        """Calculate sector matching score (0 or 100)"""
        if user_sector.lower().strip() == internship_sector.lower().strip():
            return 100.0
        return 0.0
    
    def _calculate_location_match(self, user_location: str, internship_location: str) -> float:
        """Calculate location matching score with partial matching"""
        user_loc = user_location.lower().strip()
        intern_loc = internship_location.lower().strip()
        
        # Exact match
        if user_loc == intern_loc:
            return 100.0
        
        # Partial match (city in state or vice versa)
        if user_loc in intern_loc or intern_loc in user_loc:
            return 70.0
        
        # Remote work bonus
        if 'remote' in intern_loc or 'anywhere' in intern_loc:
            return 50.0
        
        return 0.0
    
    def _calculate_education_match(self, user_education: str, required_education: str) -> float:
        """Calculate education matching score"""
        education_levels = {
            '10th Pass': 1,
            '12th Pass': 2,
            'Diploma': 3,
            "Bachelor's Degree": 4,
            "Master's Degree": 5
        }
        
        user_level = education_levels.get(user_education, 0)
        required_level = education_levels.get(required_education, 0)
        
        # User meets or exceeds requirement
        if user_level >= required_level:
            return 100.0
        
        # Close match (1 level below)
        if user_level == required_level - 1:
            return 50.0
        
        return 0.0
    
    def recommend(self, education: str, skills: List[str], sector: str, location: str) -> List[Dict]:
        """
        Generate TOP 3-5 internship recommendations
        
        Returns list of internships with scores and explanations
        """
        scored_internships = []
        
        for internship in self.internships:
            # Calculate individual scores
            skill_score = self._calculate_skill_match(skills, internship['required_skills'])
            sector_score = self._calculate_sector_match(sector, internship['sector'])
            location_score = self._calculate_location_match(location, internship['location'])
            education_score = self._calculate_education_match(education, internship['education_required'])
            
            # Calculate weighted total score
            total_score = (
                skill_score * self.weights['skill_match'] +
                sector_score * self.weights['sector_match'] +
                location_score * self.weights['location_match'] +
                education_score * self.weights['education_match']
            )
            
            # Prepare result
            result = {
                'id': internship['id'],
                'title': internship['title'],
                'company': internship['company'],
                'sector': internship['sector'],
                'location': internship['location'],
                'duration': internship['duration'],
                'stipend': internship['stipend'],
                'required_skills': internship['required_skills'],
                'description': internship['description'],
                'total_score': round(total_score, 2),
                'score_breakdown': {
                    'skill_match': round(skill_score, 2),
                    'sector_match': round(sector_score, 2),
                    'location_match': round(location_score, 2),
                    'education_match': round(education_score, 2)
                },
                'explanation': self._generate_explanation(
                    skill_score, sector_score, location_score, education_score
                )
            }
            
            scored_internships.append(result)
        
        # Sort by total score (descending)
        scored_internships.sort(key=lambda x: x['total_score'], reverse=True)
        
        # Return TOP 3-5 recommendations
        top_recommendations = scored_internships[:5]
        
        # Filter: only return if score > 20 (basic relevance threshold)
        filtered = [r for r in top_recommendations if r['total_score'] > 20]
        
        return filtered[:5]  # Maximum 5 recommendations
    
    def _generate_explanation(self, skill_score: float, sector_score: float, 
                             location_score: float, education_score: float) -> str:
        """Generate human-readable explanation"""
        explanations = []
        
        if skill_score >= 60:
            explanations.append("Strong skill match")
        elif skill_score >= 30:
            explanations.append("Partial skill match")
        
        if sector_score == 100:
            explanations.append("Perfect sector fit")
        
        if location_score >= 70:
            explanations.append("Good location match")
        
        if education_score == 100:
            explanations.append("Meets education requirement")
        
        if not explanations:
            return "Basic match - worth exploring"
        
        return " • ".join(explanations)