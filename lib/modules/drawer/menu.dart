import 'package:flutter/material.dart';

const menu = [
  {
    'role':0, 'description':'Guest',
    'menu':[
    {'title':'Subscribe','icon':Icons.subscriptions,'navigator':'/subscribe','priority':1},
    {'title':'About','icon':Icons.account_box,'navigator':'/about','priority':9},
    ]
  },
  {
    'role':1, 'description':'Shop Assistant',
    'menu':[
    {'title':'Shops','icon':Icons.shop_two,'navigator':'/shops','priority':0},
    ]
  },
  {
    'role':2, 'description':'Business owner',
    'menu':[
    {'title':'Customers','icon':Icons.people,'navigator':'/clients','priority':2},
    {'title':'Users','icon':Icons.people_outline,'navigator':'/users','priority':4},
    ]
  },
  {
    'role':3, 'description':'Administrator',
    'menu':[
    {'title':'Migration','icon':Icons.import_export,'navigator':'/migrate','priority':3},
    ]
  },
];