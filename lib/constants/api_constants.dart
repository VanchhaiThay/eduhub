// NewsData.io API base endpoint
const String newsApiBaseUrl = 'https://newsdata.io/api/1/latest';

// Cambodia education news query
const String newsCambodiaQuery = '&country=kh&category=education&language=en';

// Scholarship query - focused on education-related scholarships
const String newsScholarshipQuery =
    '&q=scholarship%20OR%20education%20grant%20OR%20student%20fellowship&category=education&language=en';

// Fallback: broader Asian education news if Cambodia-specific returns empty
const String newsAsiaEducationQuery =
    '&category=education&language=en&country=kh,th,vn,sg,my,id,ph';
