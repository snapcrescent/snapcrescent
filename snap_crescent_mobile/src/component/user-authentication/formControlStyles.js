import { StyleSheet } from 'react-native';

export const BACKGROUND_IMAGE = require('../../assets/background.jpg');

const FormControlStyle = StyleSheet.create({
    container: {
        flex: 1,
        flexDirection: 'column'
    },
    background: {
        flex: 1,
        resizeMode: "cover",
    },
    centerAlignContainer: {
        justifyContent: 'center',
        alignItems: 'center'
    },
    textInput: {
        height: 40,
        borderColor: 'gray',
        borderWidth: 1,
        borderRadius: 5,
        marginTop: 10,
        marginBottom: 10
    },
    errorContainer: {
        flex: 1
    },
    errorMessage: {
        color: 'red'
    },
    navigationLink: {
        marginTop: 5,
        marginBottom: 5,
        alignItems: 'center',
        justifyContent: 'center'
    },
    submitButton: {
        marginTop: 10,
    },
    cardContainer: {
        width: '80%',
        justifyContent: 'center',
        borderRadius: 10
    }
});

export default FormControlStyle;