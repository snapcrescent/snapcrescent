Please gradle.properties at C:\Users\<USER>\.gradle\

cd <project root>
npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle  --assets-dest android/app/src/main/res/
 
--Delete following folders--
android\app\src\main\res\raw\*
android\app\src\main\res\drawable*

cd <project root>\android
./gradlew assembleRelease