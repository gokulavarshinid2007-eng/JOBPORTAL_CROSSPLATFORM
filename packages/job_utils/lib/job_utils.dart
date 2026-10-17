/// job_utils
///
/// A small custom Dart package created for the Job Portal app.
/// It holds reusable helper functions that don't belong to any one
/// screen — so any page (Home, Login, Register, Splash, etc.) can
/// import this package and reuse the same logic.
library job_utils;

/// Capitalizes the first letter of a word.
/// Example: capitalize('fresher') -> 'Fresher'
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Formats a raw number string into an Indian Rupee salary display.
/// Example: formatSalary('30000') -> '₹30,000/month'
String formatSalary(String amount) {
  return '₹$amount/month';
}

/// Our small "useless" easter-egg function, moved here so it now lives
/// inside our own custom package instead of directly in a page file.
String getRandomUselessJoke() {
  final jokes = [
    "Why did the resume go to therapy? Too many unresolved gaps.",
    "I applied for 99 jobs... and the interviewer said 'still none'.",
    "My cover letter has more drama than a soap opera.",
    "Job hunting: the only sport where rejection is the trophy.",
  ];
  jokes.shuffle();
  return jokes.first;
}

/// Simple email format check, reusable across Login and Register forms.
bool isValidEmail(String email) {
  return email.contains('@') && email.contains('.');
}