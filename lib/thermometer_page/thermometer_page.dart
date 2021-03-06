import 'package:alcool_app/helper.dart';
import 'package:alcool_app/model/drink.dart';
import 'package:alcool_app/model/user.dart';
import 'package:alcool_app/thermometer_page/new_drink_modal.dart';
import 'package:alcool_app/providers/users.dart';
import 'package:alcool_app/thermometer_page/thermometer_scale.dart';
import 'package:animated_background/animated_background.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'liquid_custom_progress_indicator.dart';

class ThermometerPage extends StatefulWidget {
  static const routeName = '/thermometer';

  @override
  _ThermometerPageState createState() => _ThermometerPageState();
}

class _ThermometerPageState extends State<ThermometerPage>
    with TickerProviderStateMixin {
  double _previewPourcentage = 0;
  BuildContext _context;

  void _previewNewDrink(
      {double newVolume, double newPourcentage, DateTime newTime}) {
    final drink = Drink(
      id: 'some id',
      pourcentage: newPourcentage,
      time: newTime,
      valid: true,
      volume: newVolume,
    );

    final user = (ModalRoute.of(_context).settings.arguments as User);
    final copyUser = User(
      id: user.id,
      height: user.height,
      name: user.name,
      weight: user.weight,
      isFemale: user.isFemale,
      drinks: [...user.drinks],
    );
    copyUser.drinks.add(drink);
    setState(() {
      _previewPourcentage = Helper.percentageToDisplayOnThermometer(
          Helper.getPourcentage(copyUser));
    });
  }

  void _addNewDrink() async {
    final newDrink = await showModalBottomSheet(
      context: _context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewDrinkModal(_previewNewDrink),
          behavior: HitTestBehavior.opaque,
        );
      },
    ) as Drink;

    if (newDrink != null) {
      Provider.of<Users>(context, listen: false).addDrinkToUser(
        (ModalRoute.of(context).settings.arguments as User).id,
        newDrink,
      );
    }
    setState(() {
      _previewPourcentage = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context).settings.arguments as User;
    setState(() {
      _context = context;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.pink,
        ),
        title: Text(
          user.name,
          style: TextStyle(color: Colors.black, fontSize: 23),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: user.drinks.length == 0
                ? null
                : () {
                    return showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(
                            'Drinks History',
                            textAlign: TextAlign.center,
                          ),
                          content: Container(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height / 2,
                            child: ListView.builder(
                              itemBuilder: (ctx, index) {
                                return Card(
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(
                                      user.drinks[index].volume.toString() +
                                          ' mL at ' +
                                          user.drinks[index].pourcentage
                                              .toString() +
                                          '%',
                                    ),
                                    subtitle: Text(
                                        DateFormat('yyyy-MM-dd hh:mm:ss')
                                            .format(user.drinks[index].time)),
                                    trailing: IconButton(
                                      color: Colors.pink,
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        Provider.of<Users>(
                                          context,
                                          listen: false,
                                        ).removeDrinkFromUser(
                                          user.id,
                                          user.drinks[index],
                                        );
                                        setState(() {});
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ),
                                );
                              },
                              itemCount: user.drinks.length,
                            ),
                          ),
                        );
                      },
                    );
                  },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.topCenter,
            child: Text(
              Helper.timeUntilSober(
                Helper.getPourcentage(user),
              ),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  decoration: TextDecoration.underline),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 20,
                  bottom: MediaQuery.of(context).size.height / 15,
                ),
                child: Stack(
                  children: <Widget>[
                    LiquidCustomProgressIndicator(
                      value: 0.0,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.black,
                      ),
                      backgroundColor: Colors.black,
                      direction: Axis.vertical,
                      shapePath:
                          _buildBigThermometerPath(MediaQuery.of(context).size),
                    ),
                    LiquidCustomProgressIndicator(
                      value: Helper.percentageToDisplayOnThermometer(
                          Helper.getPourcentage(user)),
                      valueColor: null,
                      backgroundColor: Colors.white,
                      direction: Axis.vertical,
                      center: Stack(
                        children: <Widget>[
                          AnimatedBackground(
                            behaviour: RandomParticleBehaviour(
                              options: ParticleOptions(
                                baseColor: Colors.white,
                                spawnMaxSpeed: 50,
                                spawnMinSpeed: 30,
                                particleCount: 20,
                              ),
                            ),
                            vsync: this,
                            child: Container(
                              child: BorderedText(
                                strokeWidth: 3.0,
                                strokeColor: Colors.black,
                                child: Text(
                                  Helper.getPourcentage(user).toString(),
                                  style: TextStyle(
                                    fontSize: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height / 15),
                            ),
                          ),
                        ],
                      ),
                      shapePath: _buildSmallThermometerPath(
                          MediaQuery.of(context).size),
                    ),
                    LiquidCustomProgressIndicator(
                      value: _previewPourcentage,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.pink,
                      ),
                      backgroundColor: Colors.transparent,
                      direction: Axis.vertical,
                      shapePath: _buildSmallThermometerPath(
                          MediaQuery.of(context).size),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ThermometerScale(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () => _addNewDrink(),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Path _buildSmallThermometerPath(Size size) {
    double width = size.width * 0.5;
    double height = size.height * 0.73;

    Path path = Path();
    path.lineTo(width * (1.02 - 0.22), height * 0.75);
    path.cubicTo(width * (1.02 - 0.22), height * 0.53, width * (1.02 - 0.22),
        height * 0.09, width * (1.02 - 0.22), height * 0.07);
    path.cubicTo(width * (1.02 - 0.22), height * 0.04, width * (0.42 - 0.22),
        height * 0.04, width * (0.42 - 0.22), height * 0.07);
    path.cubicTo(width * (0.42 - 0.22), height * 0.09, width * (0.42 - 0.22),
        height * 0.53, width * (0.42 - 0.22), height * 0.75);
    path.cubicTo(width * (0.29 - 0.22), height * 0.78, width * (0.22 - 0.22),
        height * 0.83, width * (0.22 - 0.22), height * 0.88);
    path.cubicTo(width * (0.22 - 0.22), height * 0.97, width * (0.44 - 0.22),
        height * 1.05, width * (0.72 - 0.22), height * 1.05);
    path.cubicTo(width * (1 - 0.22), height * 1.05, width * (1.22 - 0.22),
        height * 0.97, width * (1.22 - 0.22), height * 0.88);
    path.cubicTo(width * (1.21 - 0.22), height * 0.83, width * (1.14 - 0.22),
        height * 0.78, width * (1.02 - 0.22), height * 0.75);
    path.cubicTo(width * (1.02 - 0.22), height * 0.75, width * (1.02 - 0.22),
        height * 0.75, width * (1.02 - 0.22), height * 0.75);
    path.close();
    return path;
  }

  Path _buildBigThermometerPath(Size size) {
    double width = size.width * 0.53;
    double height = size.height * 0.742;

    Path path = Path();
    path.lineTo(width * (1.02 - 0.248), height * (0.75 - 0.01));
    path.cubicTo(
        width * (1.02 - 0.248),
        height * (0.53 - 0.01),
        width * (1.02 - 0.248),
        height * (0.09 - 0.01),
        width * (1.02 - 0.248),
        height * (0.07 - 0.01));
    path.cubicTo(
        width * (1.02 - 0.248),
        height * (0.04 - 0.01),
        width * (0.42 - 0.248),
        height * (0.04 - 0.01),
        width * (0.42 - 0.248),
        height * (0.07 - 0.01));
    path.cubicTo(
        width * (0.42 - 0.248),
        height * (0.09 - 0.01),
        width * (0.42 - 0.248),
        height * (0.53 - 0.01),
        width * (0.42 - 0.248),
        height * (0.75 - 0.01));
    path.cubicTo(
        width * (0.29 - 0.248),
        height * (0.78 - 0.01),
        width * (0.22 - 0.248),
        height * (0.83 - 0.01),
        width * (0.22 - 0.248),
        height * (0.88 - 0.01));
    path.cubicTo(
        width * (0.22 - 0.248),
        height * (0.97 - 0.01),
        width * (0.44 - 0.248),
        height * (1.05 - 0.01),
        width * (0.72 - 0.248),
        height * (1.05 - 0.01));
    path.cubicTo(
        width * (1 - 0.248),
        height * (1.05 - 0.01),
        width * (1.22 - 0.248),
        height * (0.97 - 0.01),
        width * (1.22 - 0.248),
        height * (0.88 - 0.01));
    path.cubicTo(
        width * (1.21 - 0.248),
        height * (0.83 - 0.01),
        width * (1.14 - 0.248),
        height * (0.78 - 0.01),
        width * (1.02 - 0.248),
        height * (0.75 - 0.01));
    path.cubicTo(
        width * (1.02 - 0.248),
        height * (0.75 - 0.01),
        width * (1.02 - 0.248),
        height * (0.75 - 0.01),
        width * (1.02 - 0.248),
        height * (0.75 - 0.01));
    path.close();
    return path;
  }
}
