import os
import json
import argparse
import pandas as pd
import glob

parser = argparse.ArgumentParser(description='OpenCV PerfTest result parser', formatter_class=argparse.RawTextHelpFormatter)

parser.add_argument('-bs', '--base_single', type=str, default='', help='base single test result json file')
parser.add_argument('-bm', '--base_multi', type=str, default='', help='base multi test result json file')
parser.add_argument('-ss', '--simd_single', type=str, default='', help='simd single test result json file')
parser.add_argument('-sm', '--simd_multi', type=str, default='', help='simd multi test result json file')
parser.add_argument('-s', '--summary', type=str, default='', help='generate the summary file')
parser.add_argument('-m', '--merge', nargs='+', type=str, default='', help='merge summary csv file to excel \n  [sheet name] [csv file]\n  [sheet name] [csv file]\n  ...')
parser.add_argument('-ms', '--toms', action='store_true', help='convert origin ns to ms')
parser.add_argument('-jp', '--json_path', type=str, default='', help='json file path for single test')

args = parser.parse_args()


def parse_file(file, indf):
    with open(file, 'r') as fjson:
        json_content = json.loads(fjson.read())
        testsuites = json_content['testsuites']
        for its in testsuites:
            if(its['failures'] != 0):
                continue
            tsname = its['name']
            testsuite = its['testsuite']
            for itc in testsuite:
                ilist = []
                ilist.append(tsname + '/' + itc['name'])
                if('value_param' in itc.keys()):
                    ilist.append(itc['value_param'])
                else:
                    ilist.append('NaN')

                if('mean' in itc.keys()):
                    if (args.toms):
                        ilist.append(round(int(itc['mean'])/1000000.0,2))
                    else:
                        ilist.append(int(itc['mean']))
                else:
                    ilist.append(0)
                indf.loc[len(indf)] = ilist

if (args.base_single):
    bsdf = pd.DataFrame(columns=['name', 'params', 'baseSingleTH'])
    parse_file(args.base_single, bsdf)
    bsdf.to_csv(os.path.splitext(args.base_single)[0] + '.csv', index=False)

if (args.base_multi):
    bmdf = pd.DataFrame(columns=['name', 'params', 'baseMultiTH'])
    parse_file(args.base_multi, bmdf)
    bmdf.to_csv(os.path.splitext(args.base_multi)[0] + '.csv', index=False)

if (args.simd_single):
    ssdf = pd.DataFrame(columns=['name', 'params', 'SimdSingleTH'])
    parse_file(args.simd_single, ssdf)
    ssdf.to_csv(os.path.splitext(args.simd_single)[0] + '.csv', index=False)

if (args.simd_multi):
    smdf = pd.DataFrame(columns=['name', 'params', 'SimdMultiTH'])
    parse_file(args.simd_multi, smdf)
    smdf.to_csv(os.path.splitext(args.simd_multi)[0] + '.csv', index=False)

if (args.json_path):
    flist = glob.glob('*.json')
    for ifile in flist:
        jfdf = pd.DataFrame(columns=['name', 'params', 'mean'])
        parse_file(ifile, jfdf)
        jfdf.to_csv(os.path.splitext(ifile)[0] + '.csv', index=False)

if (args.summary):
    if (('bsdf' in dir()) and ('bmdf' in dir())
                        and ('ssdf' in dir())
                            and ('smdf' in dir())):
        summary_df = pd.concat([bsdf, ssdf['SimdSingleTH'], bmdf['baseMultiTH'], smdf['SimdMultiTH']], axis=1)
        summary_df['A_Speedup'] = round(summary_df['baseSingleTH']/summary_df['SimdSingleTH'],2)
        summary_df['B_Speedup'] = round(summary_df['baseSingleTH']/summary_df['baseMultiTH'],2)
        summary_df['C_Speedup'] = round(summary_df['baseSingleTH']/summary_df['SimdMultiTH'],2)
        summary_df['C>A&C>B'] = (summary_df['C_Speedup'] > summary_df['B_Speedup']) & (summary_df['C_Speedup'] > summary_df['A_Speedup']) 
        summary_df['C - MAX(A,B)'] = summary_df['C_Speedup'] - summary_df.loc[:, ['A_Speedup','B_Speedup']].max(axis=1)
        summary_df.to_csv(args.summary, index=False)
    else:
        print("Invalid Input data")

if (args.merge):
    inlist = args.merge
    if(len(inlist)%2 == 0):
        with pd.ExcelWriter('summary.xlsx') as writer:
            for isheet in range(0, len(inlist), 2):
                sname = inlist[isheet]
                df = pd.read_csv(inlist[isheet + 1])
                df.reset_index(drop=True, inplace=True)
                df.to_excel(writer, sheet_name=sname, index=False)
    else:
        print("Invalid Input")
