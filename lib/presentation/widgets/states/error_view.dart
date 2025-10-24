
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isRetrying;

  const ErrorView({
    Key? key,
    required this.error,
    required this.onRetry,
    this.isRetrying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: isSmallScreen ? 48 : 64,
                  color: Colors.red.shade400,
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 20 : 24),

            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),


            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: AppConstants.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _formatErrorMessage(error),
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: AppConstants.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isSmallScreen ? 24 : 32),

            ElevatedButton.icon(
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(Icons.refresh),
              label: Text(
                isRetrying ? 'Retrying...' : 'Try Again',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isRetrying ? 0 : 2,
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 16),

            TextButton.icon(
              onPressed: () => _showErrorDetails(context),
              icon: Icon(
                Icons.info_outline,
                size: isSmallScreen ? 16 : 18,
                color: AppConstants.textSecondary,
              ),
              label: Text(
                'View technical details',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: AppConstants.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatErrorMessage(String error) {
    if (error.contains('Connection timeout') || error.contains('Network error')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    } else if (error.contains('Server error')) {
      return 'The server encountered an error. This is usually temporary. Please try again in a moment.';
    } else if (error.contains('Unable to load asset')) {
      return 'Failed to load data files. Please ensure the app is properly installed.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void _showErrorDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.bug_report,
              color: Colors.red.shade400,
            ),
            SizedBox(width: 12),
            Text(
              'Error Details',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            error,
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppConstants.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }
}