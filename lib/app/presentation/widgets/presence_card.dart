import 'package:attendance_demo/app/presentation/widgets/label_text.dart';
import 'package:flutter/material.dart';

class PresenceCard extends StatelessWidget {
  const PresenceCard({
    Key? key,
    required this.presenceSuccess,
    required this.date,
    required this.addressLine,
  }) : super(key: key);

  final ValueNotifier<bool> presenceSuccess;
  final String date;
  final ValueNotifier<String?> addressLine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Presensi',
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Aktivitasmu hari ini',
            style: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontWeight: FontWeight.normal, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: presenceSuccess,
            builder: (context, _, __) => SizedBox(
              height: 150,
              child: Card(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.share,
                                size: 30,
                                color: Colors.blue,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                presenceSuccess.value
                                    ? 'Sudah presensi'
                                    : 'Belum Presensi',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: presenceSuccess.value
                                            ? Colors.green
                                            : Colors.red),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          LabelText(
                              icon: Icons.watch_later,
                              label: 'Waktu',
                              text: presenceSuccess.value ? date : '-'),
                          LabelText(
                              icon: Icons.location_on,
                              label: 'Lokasi',
                              text: presenceSuccess.value
                                  ? '${addressLine.value}'
                                  : '-'),
                        ],
                      ),
                    ),
                    if (presenceSuccess.value)
                      Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://randomuser.me/api/portraits/men/84.jpg',
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ))
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
