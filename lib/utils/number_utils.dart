// Number Utilities
// Helper functions for number formatting and calculations
import 'dart:math' as math;

class NumberUtils {
  // Format number with commas
  static String formatWithCommas(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
  
  // Format currency
  static String formatCurrency(double amount, {
    String symbol = '₹',
    int decimals = 2,
    bool showSymbol = true,
  }) {
    final formattedAmount = amount.toStringAsFixed(decimals);
    final formatted = formatWithCommas(double.parse(formattedAmount));
    return showSymbol ? '$symbol$formatted' : formatted;
  }
  
  // Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 B';
    
    int i = (math.log(bytes) / math.log(1024)).floor();
    double size = bytes / math.pow(1024, i);
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
  
  // Round to decimal places
  static double roundToDecimal(double value, int decimals) {
    final factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }
  
  // Clamp number between min and max
  static num clamp(num value, num min, num max) {
    return math.max(min, math.min(max, value));
  }
  
  // Check if number is within range
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }
  
  // Generate random number in range
  static int randomInt(int min, int max) {
    final random = math.Random();
    return min + random.nextInt(max - min + 1);
  }
  
  // Generate random double in range
  static double randomDouble(double min, double max) {
    final random = math.Random();
    return min + random.nextDouble() * (max - min);
  }
  
  // Calculate percentage
  static double calculatePercentage(num value, num total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  // Calculate percentage of value
  static double percentageOf(double percentage, double value) {
    return (percentage / 100) * value;
  }
  
  // Calculate discount amount
  static double calculateDiscount(double originalPrice, double discountPercentage) {
    return percentageOf(discountPercentage, originalPrice);
  }
  
  // Calculate discounted price
  static double calculateDiscountedPrice(double originalPrice, double discountPercentage) {
    final discount = calculateDiscount(originalPrice, discountPercentage);
    return originalPrice - discount;
  }
  
  // Calculate tip amount
  static double calculateTip(double billAmount, double tipPercentage) {
    return percentageOf(tipPercentage, billAmount);
  }
  
  // Calculate total with tip
  static double calculateTotalWithTip(double billAmount, double tipPercentage) {
    final tip = calculateTip(billAmount, tipPercentage);
    return billAmount + tip;
  }
  
  // Calculate tax amount
  static double calculateTax(double amount, double taxRate) {
    return percentageOf(taxRate, amount);
  }
  
  // Calculate total with tax
  static double calculateTotalWithTax(double amount, double taxRate) {
    final tax = calculateTax(amount, taxRate);
    return amount + tax;
  }
  
  // Calculate compound interest
  static double calculateCompoundInterest({
    required double principal,
    required double rate,
    required int time,
    int compoundFrequency = 1,
  }) {
    final rateDecimal = rate / 100;
    final amount = principal * math.pow(1 + (rateDecimal / compoundFrequency), compoundFrequency * time);
    return amount - principal;
  }
  
  // Calculate simple interest
  static double calculateSimpleInterest({
    required double principal,
    required double rate,
    required int time,
  }) {
    return (principal * rate * time) / 100;
  }
  
  // Calculate EMI (Equated Monthly Installment)
  static double calculateEMI({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    final monthlyRate = (annualRate / 100) / 12;
    final emi = (principal * monthlyRate * math.pow(1 + monthlyRate, tenureMonths)) /
        (math.pow(1 + monthlyRate, tenureMonths) - 1);
    return emi;
  }
  
  // Calculate BMI (Body Mass Index)
  static double calculateBMI(double weightKg, double heightM) {
    return weightKg / (heightM * heightM);
  }
  
  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  // Calculate distance between two points
  static double calculateDistance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return math.sqrt(dx * dx + dy * dy);
  }
  
  // Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  // Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }
  
  // Calculate area of circle
  static double circleArea(double radius) {
    return math.pi * radius * radius;
  }
  
  // Calculate circumference of circle
  static double circleCircumference(double radius) {
    return 2 * math.pi * radius;
  }
  
  // Calculate area of rectangle
  static double rectangleArea(double length, double width) {
    return length * width;
  }
  
  // Calculate perimeter of rectangle
  static double rectanglePerimeter(double length, double width) {
    return 2 * (length + width);
  }
  
  // Calculate area of triangle
  static double triangleArea(double base, double height) {
    return 0.5 * base * height;
  }
  
  // Check if number is prime
  static bool isPrime(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;
    
    for (int i = 3; i <= math.sqrt(number); i += 2) {
      if (number % i == 0) return false;
    }
    return true;
  }
  
  // Calculate factorial
  static int factorial(int n) {
    if (n < 0) throw ArgumentError('Factorial is not defined for negative numbers');
    if (n == 0 || n == 1) return 1;
    
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  // Calculate GCD (Greatest Common Divisor)
  static int gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a.abs();
  }
  
  // Calculate LCM (Least Common Multiple)
  static int lcm(int a, int b) {
    return (a.abs() * b.abs()) ~/ gcd(a, b);
  }
  
  // Convert temperature Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }
  
  // Convert temperature Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }
  
  // Convert kilometers to miles
  static double kmToMiles(double km) {
    return km * 0.621371;
  }
  
  // Convert miles to kilometers
  static double milesToKm(double miles) {
    return miles * 1.60934;
  }
  
  // Convert pounds to kilograms
  static double poundsToKg(double pounds) {
    return pounds * 0.453592;
  }
  
  // Convert kilograms to pounds
  static double kgToPounds(double kg) {
    return kg * 2.20462;
  }
  
  // Format number as ordinal (1st, 2nd, 3rd, etc.)
  static String toOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
  
  // Parse number from string safely
  static double? tryParseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }
  
  // Parse integer from string safely
  static int? tryParseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }
}