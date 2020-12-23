import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

toast.configure();

export const showSuccess = (props) =>{
    toast.success(props);
}
export const showInfo = (props) =>{
    toast.info(props);
}
export const showWarning = (props) =>{
    toast.warn(props);
}
export const showError = (props) =>{
    toast.error(props);
}