import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KIAT ANANDA GROUP'),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1,thickness: 1,color: Colors.black),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/data', arguments: 'Place 1/Current');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            "assets/sample1.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Jl. Raya Narogong No.65, RT.001/RW.001, Ciketing Udik, Kec. Bantar Gebang, Kota Bks, Jawa Barat 17153',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/data', arguments: 'Place 2/Current');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            "assets/sample2.jpg", // New image asset
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Jl. Raya Narogong No.77, Pasir Angin, Kec. Cileungsi, Kabupaten Bogor, Jawa Barat 16820',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}