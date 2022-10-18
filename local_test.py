import news_api
import simplejson
import sys, getopt

def main(argv):
    opts, args = getopt.getopt(argv,"a:")
    for opt, arg in opts:
          if opt == '-a':
            if arg == 'addfav':
                body = {
                    'id': 1,
                    'type': 'test'
                }
                event = {
                    'body': simplejson.dumps(body)
                }
                result = news_api.aws_add_fav(event, None)
                print(result)
            elif arg == "favs":
             event = {}
             result = news_api.aws_fetch_favs(event, None)
             print(result)

if __name__ == "__main__":
   main(sys.argv[1:])