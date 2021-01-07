import { StyleSheet } from 'react-native';

const FormControlStyle = StyleSheet.create({
    container: {
        margin: 10,
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    },
    background: {
        flex: 1,
        resizeMode: "cover",
        justifyContent: "center"
    },
    textInput: {
        height: 40,
        width: '80%',
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
    navigationLinks: {
        marginTop: 10,
        alignItems: 'center',
        justifyContent: 'center'
    },
    submitButton: {
        marginTop: 10,
        width: '80%'
    }
});

export default FormControlStyle;