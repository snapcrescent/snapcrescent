import React from 'react';
import { TextInput, View, StyleSheet, Button } from 'react-native';
import { postData } from '../../utils/ApiUtil';

class Login extends React.Component {

    constructor() {
        super();

        this.state = {
            username: '',
            password: ''
        }
    }

    login() {
        const resp = postData('login', this.state);
        console.warn(resp);
    }

    render() {
        return (
            <View style={styles.container}>
                <TextInput
                    style={styles.textInput}
                    placeholder="Username"
                    onChangeText={(text) => this.setState({ username: text })} />

                <TextInput
                    style={[styles.textInput, styles.marginTop10, styles.marginBottom10]}
                    secureTextEntry={true}
                    placeholder="Password"
                    onChangeText={(text) => this.setState({ password: text })} />

                <Button title="login" onPress={() => { this.login() }} />
            </View>
        );
    }
}

const styles = StyleSheet.create({
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
    marginTop10: {
        marginTop: 10
    },
    marginBottom10: {
        marginBottom: 10
    }
});

export default Login;