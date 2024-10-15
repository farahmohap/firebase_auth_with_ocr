import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormCubit extends Cubit<Map<String, dynamic>> {
  FormCubit() : super({});

  void updateFormData(String field, dynamic value) {
    final newState = Map<String, dynamic>.from(state);
    newState[field] = value;
    emit(newState);
  }

  Future<void> saveDataToFirestore() async {
    final formData = state;
    await FirebaseFirestore.instance.collection('formData').add(formData);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      updateFormData('image', pickedFile.path);
    }
  }

  Future<void> scanNationalID() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      updateFormData('nationalIdImage', pickedFile.path);
    }
  }
}
