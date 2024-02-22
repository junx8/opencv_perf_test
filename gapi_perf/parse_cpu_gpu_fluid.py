import pandas as pd


# cpu_df = prepare_df('gapi_cpu.ods', 'CPU')
def prepare_df(filename, filetype):
  df = pd.DataFrame(pd.read_html(filename)[0])
  tdf = df['Name of Test'].str.split('::', expand=True)
  df['name'] = tdf[1].str.split('/', expand=True)[0].str.replace(filetype, '')
  df['params'] = tdf[2]
  mname = filetype
  df[mname] = df['Mean'].str.replace(' ms', '').astype(float)
  ndf = df[['name','params', mname]]
  return ndf



cpu_df = prepare_df('gapi_cpu.ods', 'CPU')
gpu_df = prepare_df('gapi_gpu.ods', 'GPU')
fluid_df = prepare_df('gapi_fluid.ods', 'Fluid')

merged_df = pd.merge(cpu_df, gpu_df, on=['name', 'params'], how='inner')
merged_df = pd.merge(merged_df, fluid_df, on=['name', 'params'], how='inner')

merged_df['cpu-fluid'] = merged_df['CPU'] - merged_df['Fluid']
merged_df['gpu-fluid'] = merged_df['GPU'] - merged_df['Fluid']
merged_df['cpu-gpu'] = merged_df['CPU'] - merged_df['GPU']

merged_df.to_csv('cpu_gpu_fluid.csv')