import { StyleSheet } from 'react-native';

const AuthStyle = StyleSheet.create({
    container: {
        margin: 10,
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    },
    textInput: {
        height: 40,
        width: '80%',
        borderColor: 'gray',
        borderWidth: 1,
        borderRadius: 5
    },
    marginY10: {
        marginTop: 10,
        marginBottom: 10
    },
    error: {
        color: 'red'
    }
});

export default AuthStyle;