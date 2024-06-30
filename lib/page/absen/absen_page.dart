import 'dart:io';

import 'package:absensi_flutter/page/absen/camera_page.dart';
import 'package:absensi_flutter/page/main_page.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class AbsenPage extends StatefulWidget {
  final XFile? image;

  const AbsenPage({super.key, this.image});

  @override
  State<AbsenPage> createState() => _AbsenPageState(this.image);
}

class _AbsenPageState extends State<AbsenPage> {
  _AbsenPageState(this.image);

  File? _image_absen;
  XFile? image;
  String strAlamat = "",
      strDate = "",
      strTime = "",
      strDateTime = "",
      strStatus = "Absen Masuk";
  bool isLoading = false;
  double dLat = 0.0, dLong = 0.0;
  int dateHours = 0, dateMinutes = 0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('absensi');

  final CollectionReference _imagesCollection =
      FirebaseFirestore.instance.collection('images');
  @override
  void initState() {
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();

    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
    super.initState();
  }

  Future<void> _uploadImage() async {
    if (widget.image != null) {
      setState(() {
        _image_absen = File(widget.image!.path);
      });
    }

    if (_image_absen == null) return;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');

      UploadTask uploadTask = firebaseStorageRef.putFile(_image_absen!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("Download URL: $downloadUrl");

      // Save download URL to Firestore
      await _imagesCollection.add({'url': downloadUrl});

      submitAbsen(
          strAlamat, controllerName.text.toString(), strStatus, downloadUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload complete!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF6C3483),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Menu Absensi",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Color(0xFF6C3483),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Icon(Icons.face_retouching_natural_outlined,
                          color: Colors.white),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Absen Foto Selfie ya!",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Text(
                    "Ambil Foto",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CameraAbsenPage()));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    width: size.width,
                    height: 150,
                    child: DottedBorder(
                      radius: const Radius.circular(10),
                      borderType: BorderType.RRect,
                      color: Color(0xFF6C3483),
                      strokeWidth: 1,
                      dashPattern: const [5, 5],
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: image != null
                              ? Image.file(File(image!.path), fit: BoxFit.cover)
                              : const Icon(
                                  Icons.camera_enhance_outlined,
                                  color: Color(0xFF6C3483),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    controller: controllerName,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      labelText: "Masukan Nama Anda",
                      hintText: "Nama Anda",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      labelStyle:
                          const TextStyle(fontSize: 14, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF6C3483)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF6C3483)),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    "Lokasi Anda",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 14, 174, 107),
                      ))
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          height: 5 * 24,
                          child: TextField(
                            enabled: false,
                            maxLines: 5,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFF6C3483)),
                              ),
                              hintText: strAlamat != null
                                  ? strAlamat
                                  : strAlamat = 'Lokasi Kamu',
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(30),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(255, 14, 174, 107), //tombol
                          child: InkWell(
                            splashColor: Color.fromARGB(255, 71, 213, 154),
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (image == null ||
                                  controllerName.text.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                          "Ups, foto dan inputan tidak boleh kosong!",
                                          style: TextStyle(color: Colors.white))
                                    ],
                                  ),
                                  backgroundColor: Color.fromARGB(255, 222, 69, 69) ,
                                  shape: StadiumBorder(),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              } else {
                                _uploadImage();
                              }
                            },
                            child: const Center(
                              child: Text(
                                "Absen Sekarang",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            )),
      ),
    );
  }

  //get realtime location
  Future<void> getGeoLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      isLoading = false;
      getAddressFromLongLat(position);
    });
  }

  //get address by lat long
  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    setState(() {
      dLat = double.parse('${position.latitude}');
      dLat = double.parse('${position.longitude}');
      strAlamat =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    });
  }

  //permission location
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Layanan lokasi dinonaktifkan. Silakan aktifkan layanan.",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        backgroundColor: Color.fromARGB(255, 222, 69, 69),
        shape: StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                "Izin lokasi ditolak.",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: Color(0xFF6C3483),
          shape: StadiumBorder(),
          behavior: SnackBarBehavior.floating,
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Izin lokasi ditolak selamanya, kami tidak dapat mengakses.",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        backgroundColor: Color(0xFF6C3483),
        shape: StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    return true;
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C3483))),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text("sedang memeriksa data..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    // Contoh penutupan dialog setelah 1 detik
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Tutup dialog setelah 3 detik
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  MainPage())); // Pindah ke halaman MainPage
    });
  }

  //check format date time
  void setDateTime() async {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('HH:mm:ss');
    var dateHour = DateFormat('HH');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = "$strDate | $strTime";

      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });
  }

  //check status absent
  void setStatusAbsen() {
    if (dateHours < 8 || (dateHours == 7 && dateMinutes <= 00)) {
      strStatus = "Absen Masuk";
    } else if ((dateHours > 8 && dateHours < 16) ||
        (dateHours == 7 && dateMinutes >= 01)) {
      strStatus = "Absen Telat";
    } else if (dateHours >= 16 && dateHours < 17) {
      strStatus = "Absen Pulang";
    } else {
      strStatus = "Absen Keluar";
    }
  }

//chek nama sudah atau belum
  Future<bool> checkIfNameExists(String nama) async {
    final QuerySnapshot result = await dataCollection
        .where('nama', isEqualTo: nama.toLowerCase())
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  //submit data absent to firebase
  Future<void> submitAbsen(
      String alamat, String nama, String status, String url) async {
    bool nameExists = await checkIfNameExists(nama);
    if (nameExists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
                child: Text("Ups, Anda sudah absen.",
                    style: TextStyle(color: Colors.white)))
          ],
        ),
        backgroundColor: Colors.red,
        shape: StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
      return; // keluar dari fungsi jika nama sudah ada
    }

    _uploadImage();
    showLoaderDialog(context);
    dataCollection.add({
      'alamat': alamat,
      'nama': nama.toLowerCase(), // simpan nama dalam huruf kecil
      'keterangan': status,
      'datetime': strDateTime,
      'url': url
    }).then((result) {
      setState(() {
        Navigator.of(context).pop();
        try {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text("Yeay! Absen berhasil!",
                    style: TextStyle(color: Colors.white))
              ],
            ),
            backgroundColor: Color.fromARGB(255, 222, 69, 69),
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainPage()));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text("Ups, $e",
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Color(0xFF6C3483),
            shape: const StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ));
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text("Ups, $error",
                    style: const TextStyle(color: Colors.white)))
          ],
        ),
        backgroundColor: Color(0xFF6C3483),
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop();
    });
  }
}
