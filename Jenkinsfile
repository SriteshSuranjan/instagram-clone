pipeline {
    agent {
        label 'macos' // Ensure the Jenkins agent has Xcode and macOS
    }

    environment {
        PROJECT_DIR = 'App'
        SCHEME = 'instagram-clone'
        SDK = 'iphonesimulator'
        DESTINATION = 'platform=iOS Simulator,name=iPhone 14'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies (if using CocoaPods or Swift Package Manager)...'
                // Uncomment if using CocoaPods
                // sh 'pod install'
            }
        }

        stage('Build') {
            steps {
                echo 'Building the app...'
                sh '''
                xcodebuild \
                -scheme "$SCHEME" \
                -sdk "$SDK" \
                -destination "$DESTINATION" \
                -configuration Debug \
                clean build | tee build.log | xcpretty
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh '''
                xcodebuild \
                -scheme "$SCHEME" \
                -sdk "$SDK" \
                -destination "$DESTINATION" \
                test | tee test.log | xcpretty
                '''
            }
        }

        stage('Archive (Optional)') {
            when {
                branch 'main'
            }
            steps {
                echo 'Archiving the app for release...'
                sh '''
                xcodebuild archive \
                -scheme "$SCHEME" \
                -archivePath build/instagram-clone.xcarchive
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'rm -rf build'
        }

        success {
            echo 'Build and tests completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
